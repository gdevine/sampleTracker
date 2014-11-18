class ContainersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :correct_user,  only: [:edit, :update, :destroy]
  
  def index   
    @containers = Container.paginate(page: params[:c_page])
  end
  
  def new
    @container = Container.new
  end
  
  def create
    @container = current_user.containers.build(container_params)
    if @container.save
      flash[:success] = "Container created!"
      redirect_to @container
    else
      @containers = []
      render 'containers/new'
    end
  end

  def show
    @container = Container.find(params[:id])
    # Attach my contained samples
    @samples = @container.samples.paginate(page: params[:page])
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        qrcode = RQRCode::QRCode.new(container_url(@container.id), :level=>:m, :size => 5)
        pdf.bounding_box([0, 74], :width => 42, :height => 55) do
          pdf.render_qr_code(qrcode)
          pdf.text 'C'+@container.id.to_s, :size => 8
        end
         
        send_data pdf.render, type: "application/pdf", disposition: "inline"
      end
    end
  end
  
  def edit
    @container = Container.find(params[:id])
  end
     
  def update
    @container = Container.find(params[:id])
    if @container.update_attributes(container_params)
      flash[:success] = "Container updated"
      redirect_to @container
    else
      render 'edit'
    end
  end
  
  def destroy
    if @container.samples.empty?
      @container.destroy
      redirect_to containers_path
    else
      flash[:danger] = "Unable to delete a Container that contains samples. Relocate these first."
      redirect_to @container
    end
  end
  
  private
  
    def container_params
      params.require(:container).permit(:storage_location_id, 
                                     :container_type, 
                                     :description)
    end
     
    def correct_user
      @container = current_user.containers.find_by(id: params[:id])
      redirect_to root_url if @container.nil?
    end
  
  
end
