class SampleSet < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'sample_set_id', dependent: :destroy
  
  before_save :create_samples
  
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :num_samples, presence: true, length: { maximum: 3 }  # i.e. anything over 10000 would be unrealistic
  validates :sampling_date, presence: true
  
  
  
  def create_samples
    # create a new batch of samples based on the num_samples attribute of sample_set
    num_samples.times do |n| 
      cs = self.samples.build(facility_id: facility_id,
                              project_id: project_id,
                              owner_id: owner_id,
                              sampled: false)
      cs.save
    end
  end
  
end

