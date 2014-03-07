class Sample < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
end
