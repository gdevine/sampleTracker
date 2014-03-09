class SampleSetsController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
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
    @sample_set.status = 'Pending'
    if @sample_set.save
      create_samples
      flash[:success] = "Sample Set created!"
      redirect_to root_url
    else
      @sample_sets = []
      render 'sample_sets/new'
    end
  end
  
  def edit
    @sample_set = SampleSet.find(params[:id])
  end
  
  def update
    @sample_set = SampleSet.find(params[:id])
    if @sample_set.update_attributes(sample_set_params)
      flash[:success] = "Sample Set updated"
      redirect_to @sample_set
    else
      render 'edit'
    end
  end

  def destroy
    @sample_set.destroy
    redirect_to root_url
  end

  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples, :status, :add_info)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
    
    def create_samples
      @sample_set.num_samples.times do |n| 
        cs = current_user.samples.build(facility_id: @sample_set[:facility_id],
                                   project_id: @sample_set[:project_id],
                                   sample_set_id: @sample_set[:id],
                                   date_sampled: Date.today+(100*rand()),
                                   sampled: false)
        cs.save                                   
      end
    end
end