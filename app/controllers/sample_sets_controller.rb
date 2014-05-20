class SampleSetsController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @sample_sets = SampleSet.paginate(page: params[:ss_page])
  end
  
  def new
    @sample_set = SampleSet.new
  end
  
  def show
    @sample_set = SampleSet.find(params[:id])
    @samples = @sample_set.samples.paginate(page: params[:page])
  end

  def create
    @sample_set = current_user.sample_sets.build(sample_set_params)
    @sample_set.status = 'Pending'
    if @sample_set.save
      UserMailer.newss_email(@sample_set).deliver
      flash[:success] = "Sample Set created!"
      redirect_to root_url
    else
      @sample_sets = []
      render 'new'
    end
  end
  
  def edit
    @sample_set = SampleSet.find(params[:id])
  end
  
  def update
    @sample_set = SampleSet.find(params[:id])
    if @sample_set.update_attributes(sample_set_params)
      UserMailer.updatedss_email(@sample_set).deliver
      flash[:success] = "Sample Set updated"
      redirect_to @sample_set
    else
      render 'edit'
    end
  end

  def destroy
    @sample_set.destroy
    redirect_to sample_sets_path
  end
  
  
  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples, :status, :add_info, :ss_page)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
    
    
end