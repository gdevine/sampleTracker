class SampleSetsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :update, :edit, :create, 
                                            :destroy, :import_sample_fields, :import_subsamples, :export_samples_csv, 
                                            :export_subsamples_csv]
  before_action :correct_user, only: [:edit, :update, :destroy, :import_sample_fields, :import_subsamples, 
                                      :export_samples_csv, :export_subsamples_csv]
  
  def index   
    @sample_sets = SampleSet.paginate(page: params[:ss_page])
  end
  
  def new
    @sample_set = SampleSet.new
  end
  
  def show
    @sample_set = SampleSet.find(params[:id])
    @samples = @sample_set.samples.paginate(page: params[:page])
    subsamples = []
    @sample_set.samples.each do |s| 
      s.subsamples.each do |ss|
        subsamples << ss
      end
    end
    @subsamples = subsamples.paginate(page: params[:page])
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
    if @sample_set.destroy
      redirect_to dashboard_path
    else 
      flash[:danger] = @sample_set.errors.full_messages.to_sentence
      redirect_to @sample_set
    end
  end
  
  def export_samples_csv
    #
    # Export my samples in a blank csv template 
    #
    @sample_set = SampleSet.find(params[:id])
    myid = @sample_set.id.to_s
    mysurname = @sample_set.owner.surname.delete(' ')
    myfac = @sample_set.facility.code.to_s
    send_data @sample_set.export_samples_csv, filename: 'Samples'+'_'+mysurname+'_'+myfac+'_'+myid+'.csv'  
  end
  
  def export_subsamples_csv
    #
    # Export a blank csv template for uploading subsamples of my samples 
    #
    @sample_set = SampleSet.find(params[:id])
    myid = @sample_set.id.to_s
    mysurname = @sample_set.owner.surname.delete(' ')
    myfac = @sample_set.facility.code.to_s
    send_data @sample_set.export_subsamples_csv, filename: 'Subsamples'+'_'+mysurname+'_'+myfac+'_'+myid+'.csv'  
  end
  
  def import_sample_fields
    #
    # Import sample information for a sample set from csv file
    #
    @sample_set = SampleSet.find(params[:id])
    # Only proceed to upload if embedded sample IDs belong to the current Sample Set
    if valid_csv_ids(@sample_set, params['file'].path)
      CSV.foreach(params['file'].path, headers: true) do |row|
          sample_fields = row.to_hash
          Sample.import_fields(sample_fields)
      end
      flash[:success] = "Samples imported successfully"
      redirect_to @sample_set
    else 
      flash[:danger] = "Sample ID not in Sample set"
      redirect_to @sample_set
    end      
  end
  
  def import_subsamples
    #
    # Import Subsamples of my samples from an uploaded csv file
    #
    @sample_set = SampleSet.find(params[:id])
    # Only proceed to upload if embedded sample IDs belong to the current Sample Set
    if valid_csv_ids(@sample_set, params['file'].path)
      CSV.foreach(params['file'].path, headers: true) do |row|
          subsample_fields = row.to_hash
          Sample.import_subsample(subsample_fields)
      end
      flash[:success] = "Samples imported successfully"
      redirect_to @sample_set
    else 
      flash[:danger] = "Sample ID not in Sample set"
      redirect_to @sample_set
    end      
    
  end
  
  
  def valid_csv_ids(sample_set, file)
    #
    # Check that Sample IDs embedded in an uploaded Sample OR Subsample CSV file belong to the parent Sample Set
    #
    sample_ids = []
    valid = true
    # Add all Sample Set Sample IDs to a master array
    sample_set.samples.each do |x| sample_ids << x.id.to_s end
    # Loop through each row of the CSV and check ID against master array, throwing an error if it does not match   
    CSV.foreach(file, headers: true) do |row|
      sample_hash = row.to_hash
      if !sample_ids.include?(sample_hash['Sample_ID'])
        sample_set.errors.add :base, "Sample ID not in Sample set"
        valid = false
        break
      end
    end
    return valid
  end
  
  
  private

    def sample_set_params
      params.require(:sample_set).permit(:owner_id, :facility_id, :project_id, :sampling_date, :num_samples, :add_info, :ss_page)
    end
    
    def correct_user
      @sample_set = current_user.sample_sets.find_by(id: params[:id])
      redirect_to root_url if @sample_set.nil?
    end
    
end