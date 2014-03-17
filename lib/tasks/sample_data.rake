namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    
    # Create an admin user
    admin = User.create!(firstname: "Gerard",
                         surname: "Devine",
                         email: "g.devine@uws.edu.au",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: true)
    
    # Create dummy users
    99.times do |n|
      firstname  = Faker::Name.first_name
      surname = Faker::Name.last_name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(firstname: firstname,
                   surname: surname,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    
    # Create dummy facilities
    10.times do |n|
      code = "FACIL-#{n+1}"
      description = "Some additional info about this facility"
      contact = User.find(n+1)
      Facility.create!(code: code,
                       description: description,
                       contact_id: contact.id)
    end    
    
    # Create dummy storage locations    
    6.times do |n|
      code = "L-#{n+1}R-#{n+3}"
      room = "#{n+3}"
      building = "L-#{n+1}"
      address = "Room #{n+3}, Building#{n+1}, HIE, University of Western Sydney, Richmond, New South Wales"
      description  = "This is a description of this storage location"
      StorageLocation.create!(code: code,
                              room: room,
                              building: building,
                              address: address,
                              description: description,
                              custodian_id: 1+ rand(4))
    end
    
    
    # Create a set of sample sets (that are still to be sampled) associated with users (samples will be created by default)
    users = User.all(limit: 5)
    50.times do
      users.each { |user| user.sample_sets.create!(facility_id: 1 + rand(7), 
                                                   project_id: 1 + rand(7), 
                                                   num_samples: 1 + rand(7),
                                                   status: 'Pending Sampling',
                                                   sampling_date: Date.today+(100*rand()),
                                                   add_info: "Some additional info about this sample set"
                                                   ) }
    end      
    
    
    # Attach a storage location to some of the samples and mark as completed
    samples = Sample.all.to_a[0..50]
    samples.each do |sample|
      sample.storage_location = StorageLocation.find(1 + rand(5))
      sample.sampled = true
      status = 'Completed'
      sample.material_type=['Leaf', 'Soil', 'Bark', 'Litter'].sample
      tree = 1+ rand(10)
      sample.save
    end    
    
  end
end