ActiveAdmin.register Project do


 form do |f|
   f.inputs "Details" do
     f.input :code
     f.input :title
     f.input :description
   end
   f.actions
 end
  
 permit_params :code, :title, :description


end
