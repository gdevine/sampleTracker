namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(firstname: "Admin",
                         surname: "User",
                         email: "example@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: true)
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
    
    users = User.all(limit: 3)
    50.times do
      users.each { |user| user.sample_sets.create!(facility_id: 1 + rand(5), 
                                                   project_id: 1 + rand(5), 
                                                   num_samples: 1 + rand(5),
                                                   status: 'Pending',
                                                   sampling_date: Date.today+(100*rand()),
                                                   add_info: "Some additional info about this sample set"
                                                   ) }
    end
    
    users = User.all(limit: 2)
    4.times do
      users.each { |user| user.facilities.create!(code: "FACIL-#{rand(200)}",
                                                  description: "Some additional info about this sample set"
                                                  ) }
    end
    
  end
end