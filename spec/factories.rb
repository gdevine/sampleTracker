FactoryGirl.define do
  factory :user do
    firstname     "Gerard"
    surname    "Devine"
    email    "gerard@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end