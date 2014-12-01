require 'prawn/qrcode'

class SamplesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :update, :edit, :create, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :set_is_primary, :only => [:create, :update]
  before_action :check_completed, only: [:destroy]
  
  def index   
    if params[:sample_set_id]
      # For generating the output excel file
      @samples = SampleSet.find(params[:sample_set_id]).samples.to_a.sort
      count = @samples.count
      respond_to do |format|
        format.html
        # format.xls do
          # myss = @samples.first.sample_set
          # myid = myss.id.to_s
          # mysurname = myss.owner.surname.delete(' ')
          # myfac = myss.facility.code.to_s
          # filename = 'Samples'+'_'+mysurname+'_'+myfac+'_'+myid
          # response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.xls"'
          # render "samples/index.xls.erb"
        # end
        format.pdf do
          pdf = Prawn::Document.new
          s = 0
          i = 1
          until s == count-1 do
            if [55, 110, 165, 220].include? s
              pdf.start_new_page
              i=1
            end
            for j in 0..4 
              break if s == count
              qrcode = RQRCode::QRCode.new(sample_url(@samples[s].id), :level=>:m, :size => 5)
              pdf.bounding_box([125*j, 11+i*63], :width => 42, :height => 55) do
                pdf.render_qr_code(qrcode)
                pdf.text 'S'+@samples[s].id.to_s, :size => 8
                s += 1
              end
            end
            break if s == count
            i += 1
          end
           
          send_data pdf.render, type: "application/pdf", disposition: "inline"
        end
      end
    else
      @search = Sunspot.search(Sample) do
        fulltext params[:search]
        facet :ring, :facility_code, :month_sampled, :material_type, :project_code, :is_primary, :sampled
        with(:ring, params[:my_ring]) if params[:my_ring].present?
        with(:facility_code, params[:myfacility]) if params[:myfacility].present?
        with(:month_sampled, params[:mymonthsampled]) if params[:mymonthsampled].present?
        with(:material_type, params[:mymaterialtype]) if params[:mymaterialtype].present?
        with(:project_code, params[:myproject]) if params[:myproject].present?
        with(:is_primary, params[:my_is_primary]) if params[:my_is_primary].present?
        with(:sampled, params[:my_sampled]) if params[:my_sampled].present?
        order_by :id, :desc
        paginate(:page => params[:s_page], :per_page => 20)
      end
      @samples = @search.results
    end
  end
    
  def new
    # If being appended to a sample set then create it and redirect back to the sample set page
    if params[:sample_set_id]
      @sample_set = SampleSet.find(params[:sample_set_id])
      @sample_set.append_sample
      redirect_to @sample_set
    end
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
    @samples = @sample.subsamples.paginate(page: params[:page])
    @analyses = @sample.analyses.paginate(page: params[:page])
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        qrcode = RQRCode::QRCode.new(sample_url(@sample.id), :level=>:m, :size => 5)
        pdf.bounding_box([0, 74], :width => 42, :height => 55) do
          pdf.render_qr_code(qrcode)
          pdf.text 'S'+@sample.id.to_s, :size => 8
        end
         
        send_data pdf.render, type: "application/pdf", disposition: "inline"
      end
    end
  end
  
  def create
    @sample = current_user.samples.build(sample_params)
    
    if @sample.save
      flash[:success] = "Sample created!"
      redirect_to @sample
    else
      @samples = []
      if sample_params[:parent_id]
        @parent = Sample.find(sample_params[:parent_id])
      end
      render 'samples/new'
    end
  end

  def edit
    @sample = Sample.find(params[:id])
    # Include details of the parent if editing a subsample
    if @sample.parent_id
      @parent = Sample.find(@sample.parent_id)
    end
  end
     
  def update
    @sample = Sample.find(params[:id])
    if @sample.update_attributes(sample_params)
      flash[:success] = "Sample updated"
      redirect_to @sample
    else
      if @sample.parent_id
        @parent = Sample.find(@sample.parent_id)
      end
      render 'edit'
    end
  end

  def destroy
    if @sample.subsamples.empty?
      @sample.destroy
      redirect_to dashboard_path
    else
      flash[:danger] = "Unable to delete a Sample with associated Subsamples. Remove any Subsamples first."
      redirect_to @sample
    end
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
 
  private
  
    def sample_params
      params.require(:sample).permit(:owner_id, 
                                     :facility_id, 
                                     :project_id,
                                     :sample_set_id,
                                     :material_type, 
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
                                     :container_id,
                                     :is_primary,
                                     :parent_id,
                                     :analysis_ids => [])
    end
     
    def correct_user
      @sample = current_user.samples.find_by(id: params[:id])
      redirect_to root_url if @sample.nil?
    end
    
    # Set correct is_primary in the params hash
    def set_is_primary
      if !sample_params['parent_id'].blank?
        params[:sample][:is_primary] = 'false'
      else
        params[:sample][:is_primary] = 'true'
      end
    end
    
    def check_completed
      @sample = Sample.find(params[:id])
      if @sample.sampled?
        flash[:danger] = "Unable to delete a Sample marked as 'completed'. Mark as 'not complete' before attempting to delete"
        redirect_to @sample
      end
    end

end