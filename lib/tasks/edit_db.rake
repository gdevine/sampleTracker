namespace :edit_db do
  desc "Transfer old empty samples to new samples "
  task old_samples_to_new: :environment do
      
      old_ss = SampleSet.find(23)
      new_ss = SampleSet.find(37) 
      new_owner_id = 3
      samples_range = [5728, 5750]
      
      # Checking that the sample range is within old_ss and only proceed if so
      ss_ids = [] 
      old_ss.samples.each do |sample| ss_ids << sample.id end
      in_ss = (ss_ids && samples_range) == samples_range
           
      if in_ss 
        # grab all samples to be changed
        samples = Sample.where(id: samples_range[0]..samples_range[1])
       
        # for each sample... 
        samples.each do |sample|
          # ...change the sample set id to the new sample set
          sample.sample_set_id = new_ss.id
          # ...add 1 to the new sample set
          new_ss.num_samples += 1
          # ...minus 1 from the old sample set
          old_ss.num_samples -= 1
          # ...change to the correct owner id
          sample.owner_id = new_owner_id
          puts old_ss.valid?
          puts new_ss.valid?
          puts sample.valid?
          old_ss.save
          new_ss.save
          sample.save
        end
        # Finally update the owner id on the new sample set    
        new_ss.owner_id = new_owner_id     
        new_ss.save
        
      end
    
  end

end
