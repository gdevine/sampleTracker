class FacilitiesController < ApplicationController
  before_action :signed_in_user, only: [:index, :new, :show, :update, :edit, :create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def index   
    @facilities = Facility.paginate(page: params[:page])
  end
    
  def new
    @facility = Facility.new
  end
  
  def show
    @facility = Facility.find(params[:id])
    @sample_sets = @facility.sample_sets.paginate(page: params[:page])
    @samples = @facility.samples.paginate(page: params[:page])
  end

  def create
    @facility = current_user.facilities.build(facility_params)
    if @facility.save
      flash[:success] = "Facility created!"
      redirect_to @facility
    else
      @facilities = []
      render 'facilities/new'
    end
  end

  def edit
    @facility = Facility.find(params[:id])
  end
     
  def update
    @facility = Facility.find(params[:id])
    if @facility.update_attributes(facility_params)
      flash[:success] = "Facility updated"
      redirect_to @facility
    else
      render 'edit'
    end
  end

  def destroy
    @facility.destroy
    redirect_to facilities_path
  end
 
 
  private
  
    def facility_params
      params.require(:facility).permit(:contact_id, 
                                     :code, 
                                     :description)
    end
     
    def correct_user
      @facility = current_user.facilities.find_by(id: params[:id])
      redirect_to root_url if @facility.nil?
    end
end