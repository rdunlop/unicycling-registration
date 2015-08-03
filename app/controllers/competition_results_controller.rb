class CompetitionResultsController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_breadcrumbs

  respond_to :html

  def index
    authorize @competition, :view_result_data?

    @competition_results = @competition.competition_results
    add_breadcrumb "Additional Results"
  end

  # POST /competitions/#/competition_results
  def create
    authorize @competition, :add_additional_results?
    @competition_result = @competition.competition_results.build
    @competition_result.results_file = params[:results_file]
    @competition_result.name = params[:custom_name]
    @competition_result.system_managed = false
    @competition_result.published = true
    @competition_result.published_date = DateTime.now

    if @competition_result.save
      flash[:notice] = "Competition Result created successfully"
    else
      flash[:alert] = "Unable to create competition result"
    end

    respond_to do |format|
      format.html do
        redirect_to @competition_result.competition
      end
    end
  end

  # DELETE /competitions/#/competition_results/1
  def destroy
    authorize @competition, :add_additional_results?
    @competition_result = CompetitionResult.find(params[:id])
    @competition_result.destroy

    respond_with(@competition_result, location: competition_path(@competition))
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_breadcrumbs
    add_breadcrumb @competition, competition_path(@competition)
  end
end
