class SampleSet < ActiveRecord::Base
  
  after_create :create_samples, on: [:create]
  before_destroy :deletable?
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :facility, :class_name => 'Facility', :foreign_key => 'facility_id'
  belongs_to :project, :class_name => 'Project', :foreign_key => 'project_id'
  has_many :samples, :class_name => 'Sample', :foreign_key => 'sample_set_id', :dependent => :destroy
  
  default_scope -> { order('created_at DESC') }
  validates :owner_id, presence: true
  validates :facility_id, presence: true
  validates :project_id, presence: true
  validates :num_samples, presence: true, :numericality => { :greater_than => 0, :less_than_or_equal_to => 250, message: "must be between 1 and 250" }  # i.e. anything over 250 would be unrealistic
  validates :sampling_date, presence: true
  
  
  def create_samples
    #
    # Create a new batch of samples based on the num_samples attribute of sample_set
    #
    num_samples.times do |n| 
      cs = self.samples.build(facility_id: facility_id,
                              project_id: project_id,
                              owner_id: owner_id,
                              is_primary: true,
                              sampled: false)
      cs.save
    end
  end 
  
  def append_sample
    #
    # Append a new sample to the current sample_set
    #
    appended_sample = self.samples.build(facility_id: self.facility_id,
                              project_id: self.project_id,
                              owner_id: owner_id,
                              is_primary: true,
                              sampled: false)
    self.num_samples += 1                          
    appended_sample.save
    self.save
  end
  
  def status
    #
    # Return the current status of a sample set based on its samples
    #
    sampled_list = []
    samples = self.samples.to_a.each do |sample| 
      sampled_list << sample.sampled.to_s 
    end
    if sampled_list.include? 'false'
      return 'Pending'
    else
      return 'Complete'
    end
  end
  
  def deletable?
    #
    # Check if I contain any completed samples, otherwise go ahead and delete me
    #
    errors.add(:base, "Can not delete a Sample Set that contains Samples marked as complete") if has_completed_samples?
    errors.blank? #return false, to not destroy the element, otherwise, it will delete.
  end
  
  def export_samples_csv
    #
    # export my samples into a CSV template (typically for filling out in pen in the field for later import)
    #
    @samples = self.samples.to_a.sort
    CSV.generate do |csv|
      column_names = %w(id date_sampled tree ring container_id storage_location_id material_type northing easting vertical amount_collected amount_stored comments)
      csv << column_names
      @samples.each do |row|
        csv << row.attributes.values_at(*column_names)
      end
    end
  end
  
  def export_subsamples_csv
    #
    # export a blank subsamples CSV template
    #
    CSV.generate do |csv|
      column_names = %w(id project_code amount_stored storage_location_id container_id comments)
      csv << column_names
    end
  end

  
  def import_samples(filepath)
    #
    # Import sample fields from a csv file into existing samples of this sample 
    # set - only writing to disk once all imported fields are verified as valid
    #
    begin 
      ActiveRecord::Base.transaction do
        CSV.foreach(filepath, headers: true) do |row|
          sample_fields = row.to_hash
          
          # Check that an entry exists for either the storage location or container
          if sample_fields['storage_location_id'].blank? && sample_fields['container_id'].blank?
              raise "A valid storage location id or container id is needed under sample #{sample_fields['id']}"
          end
          
          # Check that if the storage location is empty a valid container is given  
          if sample_fields['storage_location_id'].blank? && !Container.find_by(id:sample_fields['container_id'])
              raise "A valid container id is needed under sample #{sample_fields['id']} (given no storage location has been given)"
          end   
          
          # Check that if only a storage location is provided that it is a valid one
          if sample_fields['container_id'].blank? && !StorageLocation.find_by(id:sample_fields['storage_location_id'])
              raise "A valid storage location id is needed under sample #{sample_fields['id']} (given no container has been given)"
          end  
        
          sample = Sample.find_by_id(sample_fields["id"])
          
          sample.update_attributes!(
                                    date_sampled: sample_fields['date_sampled'].to_s,
                                    tree: sample_fields['tree'].to_s,
                                    ring: sample_fields['ring'].to_s,
                                    container_id: sample_fields['container_id'].to_s,
                                    storage_location_id: sample_fields['storage_location_id'].to_s,
                                    material_type: sample_fields['material_type'].to_s,
                                    northing: sample_fields['northing'].to_s,
                                    easting: sample_fields['easting'].to_s,
                                    vertical: sample_fields['vertical'].to_s,
                                    amount_collected: sample_fields['amount_collected'].to_s,
                                    amount_stored: sample_fields['amount_stored'].to_s,
                                    comments: sample_fields['comments'].to_s,
                                    sampled:true,
                                    is_primary:true
                                    )
        end
      end
      return
    rescue => e 
      return e.to_s
    end
  end
  
  
  def import_subsamples(filepath)
    #
    # Import subsample fields from a csv file - only writing to disk once all imported fields are verified as valid
    #
    begin 
      ActiveRecord::Base.transaction do
        CSV.foreach(filepath, headers: true) do |row|
          subsample_fields = row.to_hash
          
          # check that the project exists
          if !Project.find_by_code(subsample_fields['project_code'])
            raise "The Project code #{subsample_fields['project_code']} can not be found"
          end
          
          # Check that an entry exists for either the storage location or container
          if subsample_fields['storage_location_id'].blank? && subsample_fields['container_id'].blank?
              raise "A valid storage location id or container id is needed under sample #{subsample_fields['id']}"
          end
          
          # Check that if the storage location is empty a valid container is given  
          if subsample_fields['storage_location_id'].blank? && !Container.find_by(id:subsample_fields['container_id'])
              raise "A valid container id is needed under sample #{subsample_fields['id']} (given no storage location has been given)"
          end   
          
          # Check that if only a storage location is provided that it is a valid one
          if subsample_fields['container_id'].blank? && !StorageLocation.find_by(id:subsample_fields['storage_location_id'])
              raise "A valid storage location id is needed under sample #{subsample_fields['id']} (given no container has been given)"
          end  
               
          parent = Sample.find_by_id(subsample_fields["id"])
          subsample= Sample.create!(parent_id: parent.id, 
                owner_id: parent.owner.id,           
                sampled: true,            
                date_sampled: parent.date_sampled,       
                facility_id: parent.facility.id,        
                project_id: Project.find_by_code(subsample_fields['project_code'].to_s).id.to_s,         
                comments: subsample_fields['comments'].to_s,           
                is_primary: false,         
                ring: parent.ring,               
                tree: parent.tree,              
                northing: parent.northing,           
                easting: parent.easting,            
                vertical: parent.vertical,           
                material_type: parent.material_type,      
                amount_collected: parent.amount_collected,   
                amount_stored: subsample_fields['amount_stored'].to_s,        
                storage_location_id: subsample_fields['storage_location_id'].to_s,        
                container_id: subsample_fields['container_id'].to_s      
                )
        end
      end
      return
    rescue => e 
      return e.to_s
    end
  end

  
  private
  
    def has_completed_samples?
      #
      # Returns true if current sample set containes samples that are marked as sampled=true
      #
      if self.samples.exists?
        @samples = self.samples.to_a
        csa = @samples.select {|cs| cs["sampled"] == true}
        return true if !csa.empty? 
      end
      false
    end
  
  
end
