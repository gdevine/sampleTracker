class Analysis < ActiveRecord::Base
  has_and_belongs_to_many :samples
  
  default_scope -> { order('created_at DESC') }
  
  validates :title, presence: true
  validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
