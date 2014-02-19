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
  end
end