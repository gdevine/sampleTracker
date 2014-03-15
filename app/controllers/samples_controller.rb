require 'rqrcode'

class SamplesController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    if params[:sample_set_id]
      # For generating the output excel file
      @samples = SampleSet.find(params[:sample_set_id]).samples.paginate(page: params[:page])
    else
      @samples = Sample.paginate(page: params[:page])
    end
  end
    
  def new
    @sample = Sample.new
  end
  
  def show
    @sample = Sample.find(params[:id])
    @qr = RQRCode::QRCode.new( sample_url, :size => 3, :level => :l )
  end

  def create
    @sample = current_user.samples.build(sample_params)
    if @sample.save
      flash[:success] = "Sample created!"
      redirect_to root_url
    else
      @samples = []
      render 'samples/new'
    end
  end

  def edit
    @sample = Sample.find(params[:id])
  end
     
  def update
    @sample = Sample.find(params[:id])
    if @sample.update_attributes(sample_params)
      flash[:success] = "Sample updated"
      redirect_to @sample
    else
      render 'edit'
    end
  end

  def destroy
    @sample.destroy
    redirect_to samples_path
  end
 
 
  private
  
    def sample_params
      params.require(:sample).permit(:owner_id, 
                                     :facility_id, 
                                     :project_id,
                                     :sample_set_id, 
                                     :tree, 
                                     :date_sampled, 
                                     :sampled, 
                                     :comments)
    end
     
    def correct_user
      @sample = current_user.samples.find_by(id: params[:id])
      redirect_to root_url if @sample.nil?
    end
end