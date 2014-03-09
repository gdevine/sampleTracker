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
    status 'Pending'
    add_info 'Some info about this sample set'
    sampling_date Date.new(2012, 12, 3)
    association :owner, :factory  => :user
  end

  factory :sample do
    sampled 'true'        
    date_sampled Date.new(2013, 11, 7)   
    storage_location 'L9 Storage Room'
    facility_id 3    
    project_id 45     
    comments "Some comments I've added"       
    is_primary true     
    ring 3           
    tree 4           
    plot 6           
    northing 65.3       
    easting 160.0        
    vertical 12.4       
    material_type 'leaf'  
    amount_collected '40g'
    amount_stored '40g'  
    
    association :owner, :factory  => :user
    association :sample_set, :factory  => :sample_set
  end
end