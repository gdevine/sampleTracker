class StorageLocation < ActiveRecord::Base
  belongs_to :custodian, :class_name => 'User', :foreign_key => 'custodian_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'storage_location_id', :dependent => :restrict_with_exception
  has_many :containers, :class_name => 'Container', :foreign_key => 'storage_location_id', :dependent => :restrict_with_exception
  default_scope -> { order('code ASC') }
  
  validates :custodian_id, presence: true
  validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
  validates :address, presence: true
end
