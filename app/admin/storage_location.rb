ActiveAdmin.register StorageLocation do

form do |f|
   f.inputs "Details" do
     f.input  :code
     f.input  :building
     f.input  :room
     f.input  :description
     f.input  :address
     
   end
   f.inputs "Content" do
     f.input :custodian, :collection => User.all.map{ |user| [user.firstname + ' ' + user.surname, user.id] }
   end
   f.actions
 end
  
 permit_params :code, :building, :room, :description, :address, :custodian_id

end
