ActiveAdmin.register Project do


form do |f|
  f.inputs "Details" do
    f.input :firstname             
    f.input :surname               
    f.input :email               
    f.input :admin
    f.input :reset_password_sent_at
    f.input :remember_created_at  
    f.input :sign_in_count        
    f.input :current_sign_in_at    
    f.input :last_sign_in_at      
    f.input :current_sign_in_ip  
    f.input :last_sign_in_ip      
    f.input :approved   
  end
  f.actions
end
  
 permit_params :firstname, 
               :surname, 
               :email, 
               :admin, 
               :reset_password_sent_at,
               :remember_created_at,  
               :sign_in_count,        
               :current_sign_in_at,    
               :last_sign_in_at,      
               :current_sign_in_ip,  
               :last_sign_in_ip,      
               :approved


end
