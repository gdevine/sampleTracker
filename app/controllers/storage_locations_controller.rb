class StorageLocationsController < ApplicationController
  before_action :signed_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @storage_locations = StorageLocation.paginate(page: params[:page])
  end
    
  def new
    @storage_location = StorageLocation.new
  end
  
  def show
    @storage_location = StorageLocation.find(params[:id])
    @samples = @storage_location.samples.paginate(page: params[:page])
  end

  def create
    @storage_location = current_user.storage_locations.build(storage_location_params)
    if @storage_location.save
      flash[:success] = "Storage location created!"
      redirect_to @storage_location
    else
      @storage_locations = []
      render 'storage_locations/new'
    end
  end

  def edit
    @storage_location = StorageLocation.find(params[:id])
  end
     
  def update
    @storage_location = StorageLocation.find(params[:id])
    if @storage_location.update_attributes(storage_location_params)
      flash[:success] = "Storage location updated"
      redirect_to @storage_location
    else
      render 'edit'
    end
  end

  def destroy
    if @storage_location.samples.empty?
      @storage_location.destroy
      redirect_to storage_locations_path
    else
      flash[:error] = "Unable to delete a Storage location that contains samples and/or containers. Relocate these first."
      redirect_to @storage_location
    end
  end
 
 
  private
  
    def storage_location_params
      params.require(:storage_location).permit(:custodian_id, 
                                     :code, 
                                     :description,
                                     :building,
                                     :room,
                                     :address)
    end
     
    def correct_user
      @storage_location = current_user.storage_locations.find_by(id: params[:id])
      redirect_to root_url if @storage_location.nil?
    end
    
end