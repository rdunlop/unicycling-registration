class PublicResultsController < ApplicationController
  before_action :skip_authorization
  before_action :load_competition_result
  before_action :check_is_published

  def show
    redirect_to @competition_result.results_file_url
  end

  private

  def load_competition_result
    @competition_result = CompetitionResult.active.find(params[:id])
  end

  def check_is_published
    redirect_to root_path unless @competition_result.competition.published?
  end
end
