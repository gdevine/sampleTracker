class AnalysesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  
  def index
    @analyses = Analysis.paginate(page: params[:page])
  end

  def show
    @analysis = Analysis.find(params[:id])
  end
end
