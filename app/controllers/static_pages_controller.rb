class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @sample_sets = current_user.my_sample_sets.paginate(page: params[:page], :per_page => 20)
    end
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end