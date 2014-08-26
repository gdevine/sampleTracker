ActiveAdmin.register User do

index do
  column :id
  column :firstname
  column :surname
  column :email
  column :approved
  actions
end



form do |f|
  f.inputs "Details" do
    f.input :firstname             
    f.input :surname               
    f.input :email    
    f.input :approved   
  end
  f.actions
end
  
 permit_params :firstname, 
               :surname, 
               :email,      
               :approved

end

