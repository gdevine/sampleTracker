class SampleSetsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :show, :update, :edit, :create, :destroy, :import]
  before_action :correct_user, only: [:edit, :update, :destroy, :import]
  before_action :check_for_completed_samples, only: [:destroy]
  
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
    if @sample_set.save
      UserMailer.newss_email(@sample_set).deliver
      flash[:success] = "Sample Set created!"
      redirect_to @sample_set
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
    redirect_to dashboard_path
  end
  
  def import
    #
    # Import sample information for a sample set from csv file
    #
    @sample_set = SampleSet.find(params[:id])
    if valid_csv_upload(@sample_set, params['file'].path)
      CSV.foreach(params['file'].path, headers: true) do |row|
          sample_hash = row.to_hash
          Sample.import(sample_hash, params[:sample_set_id])
      end
      flash[:success] = "Samples imported successfully"
      redirect_to @sample_set
    else 
      flash[:danger] = "Sample ID not in Sample set"
      redirect_to @sample_set
    end
      
  end
  
  def valid_csv_upload(sample_set, file)
    sample_ids = []
    valid = true
    sample_set.samples.each do |x| sample_ids << x.id.to_s end 
    CSV.foreach(file, headers: true) do |row|
      sample_hash = row.to_hash
      if !sample_ids.include?(sample_hash['id'])
        sample_set.errors.add :base, "Sample ID not in Sample set"
        valid = false
        break
      end
    end
    return valid
  end
  
  # def validate_csv(sample_set)
    # #
    # # Validate an uploaded CSV against the current Sample Set
    # #
    # sample_ids = []
    # sample_set.samples.each do |x| sample_ids << x.id end 
    # CSV.foreach(params['file'].path, headers: true) do |row|
      # sample_hash = row.to_hash
      # if !sample_ids.include?(sample_hash['id'])
        # @samples = sample_set.samples.paginate(page: params[:page])
        # # redirect_to sample_set
        # return false
      # end
    # end
    # return true
  # end
  
  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples, :add_info, :ss_page)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
    
    def check_for_completed_samples
      @sample_set = SampleSet.find(params[:id])
      if @sample_set.samples.exists?
        @samples = @sample_set.samples.to_a
        csa = @samples.select {|cs| cs["sampled"] == true}
        if !csa.empty?  
          flash[:danger] = "Can not delete a Sample Set that contains Samples marked as complete"
          redirect_to @sample_set
        end
      end
    end
    
end