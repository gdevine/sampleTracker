class Container < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'container_id'
  default_scope -> { order('created_at DESC') }
  
  validates :owner_id, presence: true
  validates :storage_location_id, presence: true
end
