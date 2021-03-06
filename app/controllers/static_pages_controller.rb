class StaticPagesController < ApplicationController
  
  def home
  end

  def dashboard   
    if signed_in?
      @sample_sets = current_user.sample_sets.paginate(page: params[:ss_page], :per_page => 10)
      @samples = current_user.samples.paginate(page: params[:s_page], :per_page => 10)
      @containers = current_user.containers.paginate(page: params[:c_page], :per_page => 10)
    end 
  end
  
  def help
  end
  
  def about
  end
  
  def contact
  end
  
end