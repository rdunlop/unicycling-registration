class CompetitionResultsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :competition, only: [:create]
  load_and_authorize_resource through: :competition, only: :create
  load_and_authorize_resource except: :create

  respond_to :html

  # POST /competitions/#/competition_results
  def create
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
      format.html {
        redirect_to @competition_result.competition
      }
    end
  end

  # DELETE /competition_results/1
  def destroy
    target_url = competition_path(@competition_result.competition)
    @competition_result.destroy

    respond_with(@competition_result, location: target_url)
  end
end
