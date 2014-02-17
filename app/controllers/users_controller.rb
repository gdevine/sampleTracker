class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new( user_params )    # Not the final implementation!
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the HIE Sample Tracker."
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private

    def user_params
      params.require(:user).permit(:firstname, :surname, :email, :password,
                                   :password_confirmation)
    end
end
