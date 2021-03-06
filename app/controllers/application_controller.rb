class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  # include SessionsHelper
  include SamplesHelper
  

# Update for adding first name and surname to devise user model 
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  protected

  def configure_devise_permitted_parameters
    registration_params = [:firstname, :surname, :email, :password, :password_confirmation]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) { 
        |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.for(:sign_up) { 
        |u| u.permit(registration_params) 
      }
    end
  end  
  


# Function to harvest a list of facilities to populate a dropdown list
  def pop_fac_dropdown
    all_facs = Facility.all
    fac_dropdown = []
    
    all_facs.each do |fac|
      fac_dropdown.push << [fac.code.to_s, fac.id.to_i]
    end
    fac_dropdown
  end 

end
