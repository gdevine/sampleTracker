class Project < ActiveRecord::Base
  has_many :samples, :class_name => 'Sample', :foreign_key => 'project_id', :dependent => :restrict_with_exception
  has_many :sample_sets, :class_name => 'SampleSet', :foreign_key => 'project_id', :dependent => :restrict_with_exception

  default_scope -> { order('created_at DESC') }
  
  validates :title, presence: true
  validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
