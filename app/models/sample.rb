class Sample < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :project, :class_name => 'Project', :foreign_key => 'project_id'
  belongs_to :sample_set, :class_name => 'SampleSet', :foreign_key => 'sample_set_id'
  belongs_to :container, :class_name => 'Container', :foreign_key => 'container_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  belongs_to :parent, :class_name => 'Sample', :foreign_key => 'parent_id'
  has_many :subsamples, :class_name => 'Sample', :foreign_key => 'parent_id'
  has_and_belongs_to_many :analyses
  default_scope -> { order('created_at DESC') }
  
  ## Validations
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :is_primary, inclusion: { in: [true, false] }
  validates :storage_location_id, presence: true, if: "sampled?"  # A sample can't be marked as sampled if no storage location has been assigned
  validates :date_sampled, presence: true, if: "sampled?"  # A sample can't be marked as sampled if no date sampled has been assigned
  
  #Custom validations
  validate :is_primary_only_with_no_parent
  validate :sampled_only_with_valid_fields
  validate :has_parent_when_isprimary_is_false
  validate :same_storage_location_and_container_location
  validate :same_facility_between_parent_and_subsample
  
  
  after_initialize :default_values
  # Callback to update sample's location based on changed container location
  before_validation :update_sample_loc_on_cont_change, on: [:update, :create]
  # after_update :modify_subs, on: [:update]
  
  before_destroy :subtract_from_sampleset
  
  
  searchable do
    text :comments
    integer :tree
    integer :ring
    string :facility_code
    string :month_sampled
    string :material_type
    string :project_code
    string :is_primary
    string :sampled
  end
  
  def facility_code
    facility.code.to_s
  end
  
  def project_code
    project.code.to_s
  end
  
  def month_sampled
    if date_sampled?
      date_sampled.strftime("%B %Y")
    end
  end
 
  def self.to_csv(all_samples)
    CSV.generate do |csv|
      column_names = %w(id date_sampled tree plot ring container_id storage_location_id material_type northing easting vertical amount_collected amount_stored comments)
      csv << column_names
      all_samples.each do |row|
        csv << row.attributes.values_at(*column_names)
      end
    end
  end
  
  
  def self.import(sample_hash, sample_set)
    #
    #Import sample fields into an existing sample
    #
    sample = Sample.find_by_id(sample_hash["id"])
    sample_hash[:is_primary] = true
    sample_hash[:sampled] = true
    sample.update_attributes(sample_hash)
  end
  
  
  ## Custom validations
  
  def sampled_only_with_valid_fields
    errors.add(:sampled, "can only be marked as complete if valid facility fields are supplied") if
      self.sampled && !(self.plot && self.ring && self.tree) 
  end
  
  def is_primary_only_with_no_parent
    errors.add(:base, "A sample can not be marked as is_primary if it has a parent sample") if
      self.is_primary && self.parent_id 
  end
  
  def has_parent_when_isprimary_is_false
    errors.add(:base, "A non-primary sample (i.e. subsample) must have a parent") if
      self.is_primary == false && !self.parent_id 
  end
  
  def same_storage_location_and_container_location
    #To test that a sample's location is the same as a container it's held within 
    errors.add(:base, "Unable to change the location of a Sample that is housed in a container. Either remove the sample from the container or edit the location of the container directly") if
      self.container && self.container.storage_location_id != self.storage_location_id 
  end
  
  def same_facility_between_parent_and_subsample
    #To test that a sample's facility is the same as its parent
    errors.add(:base, "A sample's facility must be the same as its parent") if
      self.parent && self.facility_id != self.parent.facility_id 
    #To test that a sample's facility is the same as any subsample's facility 
    # errors.add(:base, "A sample's facility must be the same as any of it's subsamples") if
      # self.subsamples.exists? && self.subsamples.map do |ss| ss.facility_id != self.facility_id end
  end
  
  
  private
    def default_values
      self.sampled ||= false
    end
  
  protected
    
    # Update a samples' storage location to match container storage location
    def update_sample_loc_on_cont_change
       if self.container_id_changed?
         if !self.container_id.blank?
           self.storage_location_id = self.container.storage_location_id
         end
       end
    end
       
    def subtract_from_sampleset
      if self.sample_set.present?
        self.sample_set.num_samples -= 1
        self.sample_set.save
      end
    end
    
    # In the event of a parent sample edit, modify the subsamples attributes to match
    # def modify_subs
      # if self.subsamples.exists?
        # self.subsamples.map! do |x|
          # x.update_attribute(:facility_id, self.facility_id) 
          # x.update_attribute(:project_id, self.project_id )
          # x.update_attribute(:tree, self.tree)
          # x.update_attribute(:ring, self.ring)
          # x.update_attribute(:plot, self.plot)
          # x.update_attribute(:northing, self.northing)
          # x.update_attribute(:easting, self.easting)
          # x.update_attribute(:vertical, self.vertical)
          # x.update_attribute(:amount_collected, self.amount_collected)
          # x.update_attribute(:material_type, self.material_type)
          # x.update_attribute(:date_sampled, self.date_sampled)
        # end
      # end
    # end
    
end