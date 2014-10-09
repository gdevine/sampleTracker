namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    
    # Create an admin user
    admin = User.create!(firstname: "Gerard",
                         surname: "Devine",
                         email: "g.devine@uws.edu.au",
                         password: "qwertyui",
                         password_confirmation: "qwertyui")
    
    # Create an admin user
    admin = User.create!(firstname: "Vinod",
                         surname: "Kumar",
                         email: "v.kumar@uws.edu.au",
                         password: "qwertyui",
                         password_confirmation: "qwertyui")
    
    ## Create dummy users
    # 99.times do |n|
      # firstname  = Faker::Name.first_name
      # surname = Faker::Name.last_name
      # email = Faker::Internet.email
      # password  = "password"
      # User.create!(firstname: firstname,
                   # surname: surname,
                   # email: email,
                   # password: password,
                   # password_confirmation: password)
    # end
    
    # Create dummy (and a FACE) facilities
    fac = Facility.create!(code: 'TEMP_FAC',
                       description: 'This is a temporary facility entry used as a placeholder for all samples that existed prior to the Sample Tracker starting. This will be removed in time ',
                       contact_id: 1)
                       
    # 10.times do |n|
      # code = "FACIL-#{n+1}"
      # description = "Some additional info about this facility"
      # contact = User.find(n+1)
      # Facility.create!(code: code,
                       # description: description,
                       # contact_id: contact.id)
    # end    
    
    # Create dummy projects  
    1.times do |n|
      title = "The title of project P00#{n+1}"
      code = "OLD_Sample"
      description = "This is a placeholder project for all samples existing prior to the Sample Tracker. This project will be replaced in time with the real project"
      Project.create!(title: title, code: code,
                       description: description)
    end    
    
    # Create dummy analysis types  
    # 25.times do |n|
      # title = "The title of analysis type An00#{n+1}"
      # code = "An00#{n+1}"
      # description = "Some info about this analysis type"
      # Analysis.create!(title: title, code: code,
                       # description: description)
    # end  
    
    # Create dummy storage locations    
    1.times do |n|
      code = "ALL_OLD"
      room = "L9"
      building = "L9"
      address = "HIE, University of Western Sydney, Richmond, New South Wales"
      description  = "This is a placeholder storage location for all samples existing prior to the Sample Tracker. This storgae location will be replaced in time with the real location"
      StorageLocation.create!(code: code,
                              room: room,
                              building: building,
                              address: address,
                              description: description,
                              custodian_id: 1+ rand(4))
    end
    
    # Create dummy containers    
    # 10.times do |n|
      # container_type = "Type-#{n+1}"
      # description  = "This is a description of this container"
      # Container.create!(container_type: container_type,
                        # description: description,
                        # owner_id: 1+ rand(4),
                        # storage_location_id: 1+ rand(2))
    # end
    
    # Create a set of sample sets (that are still to be sampled) associated with users (samples will be created by default)
    users = User.all(limit: 1)
    32.times do
      users.each { |user| user.sample_sets.create!(facility_id: 1, 
                                                   project_id: 1, 
                                                   # num_samples: 1 + rand(30),
                                                   num_samples: 250,
                                                   sampling_date: Date.today,
                                                   add_info: "Original Batch Sample Set to allow old samples to be ingested into the Sample Tracker"
                                                   ) }
    end      
    
    
    # # Attach a storage location to some of the samples and mark as completed
    # samples = Sample.all.to_a[0..200]
    # samples.each do |sample|
      # sample.storage_location = StorageLocation.find(1 + rand(5))
      # sample.sampled = true
      # sample.material_type = ['Leaf', 'Soil', 'Bark', 'Litter'].sample
      # sample.tree = 1 + rand(10)
      # sample.ring = 1 + rand(5)
      # sample.plot = 1 + rand(7)
      # sample.date_sampled = Date.today-(100*rand())
      # sample.save
    # end    
    
  end
end