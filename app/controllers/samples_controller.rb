require 'rqrcode'

class SamplesController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    if params[:sample_set_id]
      # For generating the output excel file
      @samples = SampleSet.find(params[:sample_set_id]).samples.to_a.sort
      respond_to do |format|
        format.html
        format.csv { send_data @samples.to_csv }
        format.xls do
          myss = @samples.first.sample_set
          myid = myss.id.to_s
          mysurname = myss.owner.surname.delete(' ')
          myfac = myss.facility.code.to_s
          filename = 'Samples'+'_'+mysurname+'_'+myfac+'_'+myid
          response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.xls"'
          render "samples/index.xls.erb"
        end
      end
    else
      @search = Sample.search do
        fulltext params[:search]
        facet :facility_code, :tree, :month_sampled, :material_type, :project_id
        with(:tree, params[:mytree]) if params[:mytree].present?
        with(:facility_code, params[:myfacility]) if params[:myfacility].present?
        with(:month_sampled, params[:mymonthsampled]) if params[:mymonthsampled].present?
        with(:material_type, params[:mymaterialtype]) if params[:mymaterialtype].present?
        with(:project_id, params[:myprojectid]) if params[:myprojectid].present?
        paginate(:page => params[:page], :per_page => 20)
      end
      # @samples = Sample.paginate(page: params[:page])
      @samples = @search.results
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
    
    def qr_code
      respond_to do |format|
        format.html
        format.svg  { render :qrcode => request.url, :level => :l, :unit => 10 }
        format.png  { render :qrcode => request.url }
        format.gif  { render :qrcode => request.url }
        format.jpeg { render :qrcode => request.url }
      end
    end

end