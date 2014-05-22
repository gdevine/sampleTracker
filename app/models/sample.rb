class Sample < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :sample_set, :class_name => 'SampleSet', :foreign_key => 'sample_set_id'
  belongs_to :storage_location, :class_name => 'StorageLocation', :foreign_key => 'storage_location_id'
  belongs_to :parent, :class_name => 'Sample', :foreign_key => 'parent_id'
  has_many :subsamples, :class_name => 'Sample', :foreign_key => 'parent_id'
  default_scope -> { order('created_at DESC') }
  
  ## Validations
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :storage_location_id, presence: true, if: "sampled?"  # A sample can't be marked as sampled if no storage location has been assigned
  validates :date_sampled, presence: true, if: "sampled?"  # A sample can't be marked as sampled if no date sampled has been assigned
  validate :sampled_only_with_valid_fields
  
  # validates :parent_id, presence: false, if: Proc.new { |a| a.is_primary? }
  # validates :parent_id, presence: true, if: Proc.new { |a| !a.is_primary? }
  
  after_initialize :default_values

  searchable do
    text :comments
    integer :tree
    string :facility_code
    string :month_sampled
    string :material_type
    integer :project_id
  end
  
  def facility_code
    facility.code.to_s
  end
  
  def month_sampled
    if date_sampled?
      date_sampled.strftime("%B %Y")
    end
  end
 
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |sample|
        csv << sample.attributes.values_at(*column_names)
      end
    end
  end
  
  def sampled_only_with_valid_fields
    errors.add(:sampled, "can only be marked as complete if valid facility fields are supplied") if
      self.sampled && !(self.plot && self.ring && self.tree) 
  end
  
  
  private
    def default_values
      self.sampled ||= false
    end
  
end
