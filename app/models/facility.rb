class Facility < ActiveRecord::Base
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'
  default_scope -> { order('code ASC') }
  
  validates :contact_id, presence: true
  validates :code, presence: true, length: { maximum: 10 }
  validates :description, presence: true
end
