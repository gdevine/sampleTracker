ActiveAdmin.register Facility do

 form do |f|
   f.inputs "Details" do
     f.input :code
     f.input :description
   end
   f.inputs "Content" do
     f.input :contact, :collection => User.all.map{ |user| [user.firstname + ' ' + user.surname, user.id] }
   end
   f.actions
 end
  
 permit_params :code, :contact_id, :description

end
