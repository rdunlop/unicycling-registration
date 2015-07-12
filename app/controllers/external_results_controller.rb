class ExternalResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, only: [:index, :create]
  before_action :load_external_result, only: [:edit, :update, :destroy]

  before_action :load_new_external_result, only: [:create]
  before_action :authorize_data_entry, except: [:index]

  before_action :set_breadcrumbs, only: :index

  # GET /competitions/#/external_results
  def index
    add_breadcrumb "Points Results"

    @external_result = ExternalResult.new
    @external_results = @competition.external_results.active

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # POST /external_results
  # POST /external_results.json
  def create
    respond_to do |format|
      @external_result.preliminary = false
      @external_result.entered_by = current_user
      @external_result.entered_at = DateTime.now
      if @external_result.save
        format.html { redirect_to competition_external_results_path(@competition), notice: 'External result was successfully created.' }
        format.json { render json: @external_result, status: :created, location: @external_result }
      else
        @external_results = @competition.external_results.active
        format.html { render action: "index" }
        format.json { render json: @external_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /external_results/1/edit
  def edit
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Edit Result"
  end

  # PUT /external_results/1
  # PUT /external_results/1.json
  def update
    respond_to do |format|
      if @external_result.update_attributes(external_result_params)
        format.html { redirect_to competition_external_results_path(@external_result.competition), notice: 'External result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @external_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /external_results/1
  # DELETE /external_results/1.json
  def destroy
    @external_result.destroy

    respond_to do |format|
      format.html { redirect_to competition_external_results_path(@competition) }
      format.json { head :no_content }
    end
  end

  private

  def authorize_data_entry
    authorize @competition, :modify_result_data?
  end

  def load_external_result
    @external_result = ExternalResult.find(params[:id])
    @competition = @external_result.competition
  end

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
