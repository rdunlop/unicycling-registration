class TrialsResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, only: %i[index create]
  before_action :load_trials_result, only: %i[edit update destroy]

  before_action :load_new_trials_result, only: [:create]
  before_action :authorize_data_entry, except: [:index]

  before_action :set_breadcrumbs, only: :index

  # GET /competitions/#/trials_results
  def index
    authorize @competition, :view_result_data?
    add_breadcrumb I18n.t("controllers.trials_results.results")

    @trials_result = TrialsResult.new
    @trials_results = @competition.trials_results.active

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # POST /competitions/#/trials_results
  # POST /competitions/#/trials_results.json
  def create
    respond_to do |format|
      @trials_result.preliminary = false
      @trials_result.entered_by = current_user
      @trials_result.entered_at = Time.current
      if @trials_result.save
        format.html { redirect_to competition_trials_results_path(@competition), notice: I18n.t("controllers.trials_results.successful_creation") }
        format.json { render json: @trials_result, status: :created, location: @trials_result }
      else
        @trials_results = @competition.trials_results.active
        format.html { render action: "index" }
        format.json { render json: @trials_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /trials_results/1/edit
  def edit
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb I18n.t("controllers.trials_results.edit_result")
  end

  # PUT /trials_results/1
  # PUT /trials_results/1.json
  def update
    respond_to do |format|
      if @trials_result.update(trials_result_params)
        format.html { redirect_to competition_trials_results_path(@trials_result.competition), notice: I18n.t("controllers.trials_results.successful_update") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @trials_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trials_results/1
  # DELETE /trials_results/1.json
  def destroy
    @trials_result.destroy

    respond_to do |format|
      format.html { redirect_to competition_trials_results_path(@competition) }
      format.json { head :no_content }
    end
  end

  private

  def authorize_data_entry
    authorize @competition, :modify_result_data?
  end

  def load_trials_result
    @trials_result = TrialsResult.find(params[:id])
    @competition = @trials_result.competition
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_trials_result
    @trials_result = @competition.trials_results.new(trials_result_params)
  end

  def trials_result_params
    params.require(:trials_result).permit(:competitor_id, :details, :points, :minutes, :seconds, :status)
  end
end
