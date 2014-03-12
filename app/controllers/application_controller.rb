class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper


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
