class SampleSetsController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @sample_sets = SampleSet.paginate(page: params[:page])
  end
  
  def new
    @sample_set = SampleSet.new
    # @choices = pop_fac_dropdown
  end
  
  def show
    @sample_set = SampleSet.find(params[:id])
    @samples = @sample_set.samples.paginate(page: params[:page])
  end

  def create
    @sample_set = current_user.sample_sets.build(sample_set_params)
    @sample_set.status = 'Pending'
    if @sample_set.save
      #create_samples
      flash[:success] = "Sample Set created!"
      redirect_to root_url
    else
      @sample_sets = []
      @choices = pop_fac_dropdown
      render 'new'
    end
  end
  
  def edit
    @sample_set = SampleSet.find(params[:id])
    @choices = pop_fac_dropdown
  end
  
  def update
    @sample_set = SampleSet.find(params[:id])
    if @sample_set.update_attributes(sample_set_params)
      flash[:success] = "Sample Set updated"
      redirect_to @sample_set
    else
      @choices = pop_fac_dropdown
      render 'edit'
    end
  end

  def destroy
    @sample_set.destroy
    redirect_to sample_sets_path
  end
  
  
  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples, :status, :add_info)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
    
    
    
end