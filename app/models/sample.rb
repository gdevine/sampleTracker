class Sample < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :sample_set, :class_name => 'SampleSet', :foreign_key => 'sample_set_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :date_sampled, presence: true
  
  searchable do
    text :comments
    integer :tree
    integer :facility_id
    # string :facility_code
  end
  
  def facility_code
    facility.code.to_s
  end
  
    
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |sample|
        csv << sample.attributes.values_at(*column_names)
      end
    end
  end
end
