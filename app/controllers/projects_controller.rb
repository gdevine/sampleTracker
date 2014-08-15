class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  
  def index
    @projects = Project.paginate(page: params[:page])
  end

  def show
    @project = Project.find(params[:id])
    @sample_sets = @project.sample_sets.paginate(page: params[:ss_page], :per_page => 10)
    @samples = @project.samples.paginate(page: params[:s_page], :per_page => 10)
  end
  
end
