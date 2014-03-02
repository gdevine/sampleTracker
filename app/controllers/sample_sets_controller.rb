class SampleSetsController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @sample_sets = SampleSet.paginate(page: params[:page])
  end
  
  def new
    @sample_set = SampleSet.new
  end
  
  def show
    @sample_set = SampleSet.find(params[:id])
  end

  def create
    @sample_set = current_user.sample_sets.build(sample_set_params)
    if @sample_set.save
      flash[:success] = "Sample Set created!"
      redirect_to root_url
    else
      @sample_sets = []
      render 'sample_sets/new'
    end
  end

  def destroy
    @sample_set.destroy
    redirect_to root_url
  end

  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
end