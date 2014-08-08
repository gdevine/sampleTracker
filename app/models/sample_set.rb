class SampleSet < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'sample_set_id', dependent: :destroy
  
  after_create :create_samples, on: [:create]
  
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :num_samples, presence: true, length: { maximum: 3 }  # i.e. anything over 10000 would be unrealistic
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
  
  
end
