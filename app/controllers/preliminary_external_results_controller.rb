class PreliminaryExternalResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, except: %i[edit update destroy]
  before_action :load_new_external_result, only: [:create]
  before_action :load_external_result, only: %i[edit update destroy]
  before_action :authorize_res
  before_action :load_external_results, only: %i[index review approve display_csv import_csv]

  before_action :set_breadcrumbs

  # GET /competitions/#/preliminary_external_results
  def index
    add_breadcrumb "Preliminary Points Results"

    @external_result = ExternalResult.new

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
      @external_result.entered_at = DateTime.current
      if @external_result.save
        format.html { redirect_to competition_preliminary_external_results_path(@competition), notice: 'External result was successfully created.' }
      else
        load_external_results
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

  # GET /competitions/:competition_id/preliminary_external_results/review
  def review
    add_breadcrumb "Review Entered Results"
  end

  # POST .../approve
  def approve
    @external_results.map{ |er| er.update_attributes(preliminary: false) }
    flash[:notice] = "Results Approved"
    redirect_to :back
  end

  # GET /competitions/:competition_id/preliminary_external_results/display_csv
  def display_csv
    add_breadcrumb "Import CSV"
  end

  # POST /competitions/#/preliminary_external_results/import_csv
  def import_csv
    uploaded_file = UploadedFile.process_params(params, competition: @competition, user: current_user)
    parser = Importers::Parsers::ExternalResultCsv.new(uploaded_file.original_file.file)
    importer = Importers::ExternalResultImporter.new(@competition, current_user)

    if importer.process(parser)
      flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
    else
      flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
    end

    redirect_to display_csv_competition_preliminary_external_results_path(@competition)
  end

  private

  def authorize_res
    authorize @competition, :create_preliminary_result?
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition) if @competition
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_external_result
    @external_result = ExternalResult.find(params[:id])
    @competition = @external_result.competition
  end

  def load_new_external_result
    @external_result = @competition.external_results.new(external_result_params)
  end

  def load_external_results
    @external_results = @competition.external_results.preliminary.reorder(:entered_at)
  end

  def external_result_params
    params.require(:external_result).permit(:competitor_id, :details, :points, :status)
  end
end
