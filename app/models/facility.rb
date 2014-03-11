class Facility < ActiveRecord::Base
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'
  has_many :sample_sets, :class_name => 'SampleSet', :foreign_key => 'facility_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'facility_id'
  default_scope -> { order('code ASC') }
  
  validates :contact_id, presence: true
  validates :code, presence: true, length: { maximum: 10 }
  validates :description, presence: true
end
