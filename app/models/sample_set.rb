class SampleSet < ActiveRecord::Base
  
  after_create :create_samples, on: [:create]
  before_destroy :deletable?
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :project, :class_name => 'Project', :foreign_key => 'project_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'sample_set_id', :dependent => :destroy
  
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :num_samples, presence: true, :numericality => { :greater_than => 0, :less_than_or_equal_to => 250, message: "must be between 1 and 250" }  # i.e. anything over 250 would be unrealistic
  validates :sampling_date, presence: true
  
  
  def create_samples
    #
    # Create a new batch of samples based on the num_samples attribute of sample_set
    #
    num_samples.times do |n| 
      cs = self.samples.build(facility_id: facility_id,
                              project_id: project_id,
                              owner_id: owner_id,
                              is_primary: true,
                              sampled: false)
      cs.save
    end
  end 
  
  def append_sample
    #
    # Append a new sample to the current sample_set
    #
    appended_sample = self.samples.build(facility_id: self.facility_id,
                              project_id: self.project_id,
                              owner_id: owner_id,
                              is_primary: true,
                              sampled: false)
    self.num_samples += 1                          
    appended_sample.save
    self.save
  end
  
  def status
    #
    # Return the current status of a sample set based on its samples
    #
    sampled_list = []
    samples = self.samples.to_a.each do |sample| 
      sampled_list << sample.sampled.to_s 
    end
    if sampled_list.include? 'false'
      return 'Pending'
    else
      return 'Complete'
    end
  end
  
  def deletable?
    #
    # Check if I contain any completed samples, otherwise go ahead and delete me
    #
    errors.add(:base, "Can not delete a Sample Set that contains Samples marked as complete") if has_completed_samples?
    errors.blank? #return false, to not destroy the element, otherwise, it will delete.
  end
  
  def export_samples_csv
    #
    # export my samples into a CSV template (typically for filling out in pen in the field for later import)
    #
    @samples = self.samples.to_a.sort
    CSV.generate do |csv|
      column_names = %w(Sample_ID date_sampled tree plot ring container_id storage_location_id material_type northing easting vertical amount_collected amount_stored comments)
      csv << column_names
      @samples.each do |row|
        csv << row.attributes.values_at(*column_names)
      end
    end
  end
  
  def export_subsamples_csv
    #
    # export a blank subsamples CSV template
    #
    CSV.generate do |csv|
      column_names = %w(Sample_ID Project_Code Amount_Stored Storage_Location_ID Container_ID Comments)
      csv << column_names
    end
  end

  
  
  private
  
    def has_completed_samples?
      #
      # Returns true if current sample set containes samples that are marked as sampled=true
      #
      if self.samples.exists?
        @samples = self.samples.to_a
        csa = @samples.select {|cs| cs["sampled"] == true}
        return true if !csa.empty? 
      end
      false
    end
  
  
end
