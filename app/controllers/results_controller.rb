class ResultsController < ApplicationController
  before_action :skip_authorization

  def index
    add_breadcrumb "Results"

    respond_to do |format|
      format.html
    end
  end

  # GET /results/registrant?registrant_id=123
  def registrant
    registrant = Registrant.find_by(id: params[:registrant_id])
    if registrant.present?
      redirect_to results_registrant_path(registrant)
    else
      flash[:alert] = "Registrant not found"
      render :index
    end
  end

  def scores
    @competition = Competition.find(params[:id])
    @combined_competition = @competition.combined_competition
    redirect_to root_url, alert: "competition has no viewable scores" if @combined_competition.nil?
  end
end
