FactoryGirl.define do
  factory :user do
    sequence(:firstname)  { |n| "Person_#{n}" }
    sequence(:surname)  { |n| "BlaBla_#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"  
    
    factory :admin do
      admin true
    end
  end
  
  factory :facility do
    sequence(:code)  { |n| "MYFAC_#{n}" }
    description 'A description of this facility'
    association :contact, :factory  => :user
  end
  
  factory :storage_location do
    sequence(:code)  { |n| "MYSL_#{n}" }
    description 'A description of this storage location'
    address "Room 32, Building L9, HIE, UWS, Richmond" 
    building "L9"
    room 32
    association :custodian, :factory  => :user
  end
  
  factory :container do
    container_type 'box'
    description 'A description of this container'
    association :owner, :factory  => :user
    association :storage_location, :factory  => :storage_location
  end
  
  factory :sample_set do
    facility_id  1 
    project_id   4
    num_samples  5
    status 'Pending'
    add_info 'Some info about this sample set'
    sampling_date Date.new(2012, 12, 3)
    
    association :owner, :factory  => :user
    association :facility, :factory  => :facility
  end

  factory :sample do        
    date_sampled Date.new(2013, 11, 7)   
    facility_id 1    
    project_id 4     
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
    sampled true
    
    association :owner, :factory  => :user
    association :facility, :factory  => :facility
    association :storage_location, :factory  => :storage_location
  end

end