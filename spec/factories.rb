FactoryGirl.define do
  factory :user do
    sequence(:firstname)  { |n| "Person #{n}" }
    sequence(:surname)  { |n| "Bla Bla #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"  
    
    factory :admin do
      admin true
    end
  end
  
  factory :sample_set do
    facility_id  1 
    project_id   1
    num_samples  50
    sampling_date Date.new(2012, 12, 3)
    association :owner, :factory  => :user
  end
end