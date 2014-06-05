class Sample < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :sample_set, :class_name => 'SampleSet', :foreign_key => 'sample_set_id'
  belongs_to :container, :class_name => 'Container', :foreign_key => 'container_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  belongs_to :parent, :class_name => 'Sample', :foreign_key => 'parent_id'
  has_many :subsamples, :class_name => 'Sample', :foreign_key => 'parent_id'
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
  
  
  after_initialize :default_values
  # Callback to update sample's location based on changed container location
  before_validation :update_sample_loc_on_cont_change, on: [:update, :create]
  # before_validation :set_is_primary, on: [:update, :create]
  
  searchable do
    text :comments
    integer :tree
    integer :ring
    string :facility_code
    string :month_sampled
    string :material_type
    integer :project_id
    string :is_primary
    string :sampled
  end
  
  def facility_code
    facility.code.to_s
  end
  
  def month_sampled
    if date_sampled?
      date_sampled.strftime("%B %Y")
    end
  end
 
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |sample|
        csv << sample.attributes.values_at(*column_names)
      end
    end
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
    
    # Update a samples' is_primary based on existance of parent
    # def set_is_primary
      # if self.parent_id.blank?
        # self.is_primary = true
      # else
        # self.is_primary = false
      # end
      # # puts self.parent_id.to_s
    # end
    
end
