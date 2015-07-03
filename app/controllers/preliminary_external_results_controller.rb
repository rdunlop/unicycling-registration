class PreliminaryExternalResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, only: [:index, :create]
  before_action :load_new_external_result, only: [:create]
  load_and_authorize_resource :external_result, parent: false

  before_action :set_breadcrumbs, only: :index

  # GET /competitions/#/preliminary_external_results
  def index
    add_breadcrumb "Preliminary Points Results"

    @external_result = ExternalResult.new
    @external_results = @external_results.preliminary

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /preliminary_external_results/1/edit
  def edit
    @competition = @external_result.competition
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Edit Result"
  end

  # POST /external_results
  # POST /external_results.json
  def create
    respond_to do |format|
      @external_result.preliminary = true
      @external_result.entered_by = current_user
      @external_result.entered_at = DateTime.now
      if @external_result.save
        format.html { redirect_to competition_preliminary_external_results_path(@competition), notice: 'External result was successfully created.' }
      else
        @external_results = @competition.external_results
        format.html { render action: "index" }
      end
    end
  end

  # PUT /external_results/1
  # PUT /external_results/1.json
  def update
    respond_to do |format|
      if @external_result.update_attributes(external_result_params)
        format.html { redirect_to competition_preliminary_external_results_path(@external_result.competition), notice: 'External result was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /external_results/1
  # DELETE /external_results/1.json
  def destroy
    @competition = @external_result.competitor.competition
    @external_result.destroy

    respond_to do |format|
      format.html { redirect_to competition_preliminary_external_results_path(@competition) }
    end
  end

  private

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_external_result
    @external_result = @competition.external_results.new(external_result_params)
  end

  def external_result_params
    params.require(:external_result).permit(:competitor_id, :details, :points, :status)
  end
end
