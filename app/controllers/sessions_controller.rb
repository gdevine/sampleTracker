class SessionsController < ApplicationController
  
  # before_action :authenticate_user!, only: [:create, :destroy]
#   
  # def new
  # end
# 
  # def create
    # # user = User.find_by(email: params[:session][:email].downcase)
    # # if user && user.authenticate(params[:session][:password])
      # sign_in user
      # redirect_back_or dashboard_url
    # # else
      # # flash.now[:danger] = 'Invalid email/password combination'
      # # render 'new'
    # # end
  # end
# 
  # def destroy
    # sign_out
    # redirect_to root_url
  # end
end
