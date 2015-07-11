class ResultsController < ApplicationController
  before_action :skip_authorization

  def index
    add_breadcrumb "Results"

    respond_to do |format|
      format.html
    end
  end

  def scores
    @competition = Competition.find(params[:id])
    @combined_competition = @competition.combined_competition
    redirect_to root_url, alert: "competition has no viewable scores" if @combined_competition.nil?
  end
end
