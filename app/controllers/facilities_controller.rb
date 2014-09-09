class FacilitiesController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  
  def index   
    @facilities = Facility.paginate(page: params[:page])
  end
    
  # def new
    # @facility = Facility.new
  # end
  
  def show
    @facility = Facility.find(params[:id])
    @sample_sets = @facility.sample_sets.paginate(page: params[:ss_page], :per_page => 10)
    @samples = @facility.samples.paginate(page: params[:s_page], :per_page => 10)
  end

  # def create
    # @facility = current_user.facilities.build(facility_params)
    # if @facility.save
      # flash[:success] = "Facility created!"
      # redirect_to @facility
    # else
      # @facilities = []
      # render 'facilities/new'
    # end
  # end
# 
  # def edit
    # @facility = Facility.find(params[:id])
  # end
#      
  # def update
    # @facility = Facility.find(params[:id])
    # if @facility.update_attributes(facility_params)
      # flash[:success] = "Facility updated"
      # redirect_to @facility
    # else
      # render 'edit'
    # end
  # end
# 
  # def destroy
    # if @facility.samples.empty? && @facility.sample_sets.empty?
      # @facility.destroy
      # redirect_to facilities_path
    # else
      # flash[:danger] = "Unable to delete a Facility that contains samples and/or sample sets."
      # redirect_to @facility
    # end
  # end
 
 
  private
  
    def facility_params
      params.require(:facility).permit(:contact_id, 
                                     :code, 
                                     :description)
    end
     
    # def correct_user
      # @facility = current_user.facilities.find_by(id: params[:id])
      # redirect_to root_url if @facility.nil?
    # end
    
end