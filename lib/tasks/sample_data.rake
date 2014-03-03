namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(firstname: "ExampleAdmin",
                         surname: "User",
                         email: "example@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar",
                         admin: true)
    99.times do |n|
      firstname  = Faker::Name.name
      surname = 'User'
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(firstname: firstname,
                   surname: surname,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    
    users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.sample_sets.create!(facility_id: 1 + rand(100), 
                                                   project_id: 1 + rand(100), 
                                                   num_samples: 1 + rand(100),
                                                   status: 'Pending',
                                                   sampling_date: Date.today+(100*rand()),
                                                   add_info: "Some additional info about this sample set"
                                                   ) }
    end
  end
end