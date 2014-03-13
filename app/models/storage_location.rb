class StorageLocation < ActiveRecord::Base
  belongs_to :custodian, :class_name => 'User', :foreign_key => 'custodian_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'storage_location_id'
  default_scope -> { order('code ASC') }
  
  validates :custodian_id, presence: true
  validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
  validates :address, presence: true
end
