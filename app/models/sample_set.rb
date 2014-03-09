class SampleSet < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'sample_set_id', dependent: :destroy
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :num_samples, presence: true, length: { maximum: 3 }  # i.e. anything over 10000 would be unrealistic
  validates :sampling_date, presence: true
end

