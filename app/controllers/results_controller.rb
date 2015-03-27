class ResultsController < ApplicationController
  skip_authorization_check
  # before_filter :authenticate_user!
  authorize_resource class: false

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
