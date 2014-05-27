class ContainersController < ApplicationController
  before_action :signed_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @containers = Container.paginate(page: params[:page])
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
    @samples = @container.samples.paginate(page: params[:page])
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
