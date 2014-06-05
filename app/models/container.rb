class Container < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'container_id'
  default_scope -> { order('created_at DESC') }
  
  validates :owner_id, presence: true
  validates :storage_location_id, presence: true
  validate :same_container_location_and_samples_location
  
  # Callback to update container sample's locations before container update
  before_validation :update_sample_locs, on: :update
  after_save :save_sample_locs, on: :update
  
  def same_container_location_and_samples_location
    #To test that a container's location is the same as the samples held within 
    locs = self.samples.map{|location| location["storage_location_id"]}  
    errors.add(:base, "A container location must match those of the samples held within") if
      !locs.all? { |item| item == self.storage_location_id }
  end
  
  protected
    
    # Update all contained samples' storage locations to match container storage location
    def update_sample_locs
      self.samples.each do |k|
        k['storage_location_id'] = self.storage_location_id
      end
    end
    
    # Save all contained samples' storage locations to match container storage location
    def save_sample_locs
      self.samples.each do |k|
        @sample = Sample.find(k[:id])
        @sample.storage_location_id = self.storage_location['id'] 
        @sample.save
      end
    end
  
end
