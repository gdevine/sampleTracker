require 'prawn/qrcode'

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
        format.pdf do
          pdf = Prawn::Document.new
          # @samples.each do |sample|
          
          samples = @samples.to_a
          s = 0
          i = 1
          while s < @samples.count-1 do
            for j in 0..4 
              qrcode = RQRCode::QRCode.new(sample_url(samples[s].id), :level=>:h, :size => 4)
              pdf.bounding_box([125*j, 11+i*63], :width => 42, :height => 55) do
                pdf.render_qr_code(qrcode)
                pdf.text samples[s].id.to_s
                s += 1
              end
            end
            i += 1
          end
           
          send_data pdf.render, type: "application/pdf", disposition: "inline"
        end
      end
    else
      @search = Sample.search do
        fulltext params[:search]
        facet :tree, :facility_code, :month_sampled, :material_type, :project_id
        with(:tree, params[:mytree]) if params[:mytree].present?
        with(:facility_code, params[:myfacility]) if params[:myfacility].present?
        with(:month_sampled, params[:mymonthsampled]) if params[:mymonthsampled].present?
        with(:material_type, params[:mymaterialtype]) if params[:mymaterialtype].present?
        with(:project_id, params[:myprojectid]) if params[:myprojectid].present?
        paginate(:page => params[:s_page], :per_page => 20)
      end
      @samples = @search.results
    end
  end
    
  def new
    # Include details of the parent if creating a new subsample
    if params[:sample_id]
      @parent = Sample.find(params[:sample_id])
    end
    @sample = Sample.new
  end
  
  def show
    @sample = Sample.find(params[:id])
    if @sample.parent_id
      @parent = Sample.find(@sample.parent_id)
    end
    @qr = RQRCode::QRCode.new( sample_url, :size => 3, :level => :l )
  end
  
  def create
    @sample = current_user.samples.build(sample_params)
    if params[:parent_id]
      @parent = Sample.find(params[:parent_id])
      @sample.parent_id = @parent
      @sample.is_primary = false
    else
      @sample.is_primary = true
    end
    
    if @sample.save
      flash[:success] = "Sample created!"
      redirect_to @sample
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
                                     :material_type, 
                                     :plot,
                                     :tree, 
                                     :ring,
                                     :date_sampled, 
                                     :sampled, 
                                     :northing,
                                     :easting,
                                     :vertical,
                                     :amount_collected,
                                     :amount_stored,
                                     :storage_location_id,
                                     :comments,
                                     :parent_id)
    end
     
    def correct_user
      @sample = current_user.samples.find_by(id: params[:id])
      redirect_to root_url if @sample.nil?
    end

end