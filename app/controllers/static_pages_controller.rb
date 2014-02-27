class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @sample_set = current_user.sample_sets.build
      @sample_sets = current_user.my_sample_sets.paginate(page: params[:page])
    end
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end