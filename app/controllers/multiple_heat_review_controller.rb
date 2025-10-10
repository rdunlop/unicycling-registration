class MultipleHeatReviewController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition_data

  before_action :set_breadcrumbs

  # GET /competitions/#/multiple_heat_review
  def index
    @lane_assignments = LaneAssignment.where(competition: @competition)
    @heat_lane_results = HeatLaneResult.where(competition: @competition)
    @heat_lane_judge_notes = HeatLaneJudgeNote.where(competition: @competition)
    @time_results = @competition.time_results.joins(:heat_lane_result).merge(HeatLaneResult.all)

    respond_to do |format|
      format.html
    end
  end

  # FOR LIF (track racing) data:
  # POST /competitions/#/multiple_heat_review/import_lif_files
  def import_lif_files
    unless @competition.uses_lane_assignments?
      flash[:alert] = "Competition not set for lane assignments"
      redirect_to competition_multiple_heat_review_index_path(@competition)
      return
    end

    uploaded_files = UploadedFile.process_params_multiple(params, competition: @competition, user: current_user)

    if uploaded_files.nil?
      flash[:alert] = "Please specify at least a file"
      redirect_to competition_multiple_heat_review_index_path(@competition)
      return
    end

    uploaded_files.each do |file|
      parser = Importers::Parsers::Lif.new(file.original_file.file)
      importer = Importers::HeatLaneLifImporter.new(@competition, current_user)

      # Extracting the heat from the filename
      match_data = /(\d+).lif$/.match(file.filename)
      if match_data.nil?
        flash[:alert] = "Error importing rows. Filename '#{file.filename}' does not finish with '{dd}.lif' ('{dd}' being any integer)."
        break
      end
      heat = match_data.captures[0]

      if importer.process(heat, parser)
        flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
      else
        flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
      end
    end
    redirect_to competition_multiple_heat_review_index_path(@competition)
  end

  # POST /competitions/#/multiple_heat_review/approve_results
  def approve_results
    authorize @competition, :create_preliminary_result?

    heat_lane_results = HeatLaneResult.where(competition_id: @competition)

    begin
      HeatLaneResult.transaction do
        heat_lane_results.each do |hlr|
          hlr.import!
        end
      end
    rescue Exception => e
      errors = e
    end

    if errors
      flash[:alert] = "Errors: #{errors}"
      redirect_back(fallback_location: competition_multiple_heat_review_index_path(@competition))
    else
      redirect_to competition_multiple_heat_review_index_path(@competition), notice: "Added results"
    end
  end

  # DELETE /competitions/#/multiple_heat_review/
  def destroy
    heat_lane_results = HeatLaneResult.where(competition_id: @competition)
    heat_lane_results.destroy_all

    redirect_to competition_multiple_heat_review_index_path(@competition), notice: "Deleted results. Try Again?"
  end

  private

  def authorize_competition_data
    authorize @competition, :create_preliminary_result?
  end

  def import_result_params
    params.require(:import_result).permit(:bib_number, :status, :minutes, :raw_data,
                                          :number_of_penalties, :seconds, :thousands, :points, :details, :is_start_time)
  end

  def load_user
    @user = User.this_tenant.find(params[:user_id])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_import_result
    @import_result = ImportResult.find(params[:id])
    @competition = @import_result.competition
  end

  def load_import_results
    @import_results = @user.import_results.where(competition_id: @competition).includes(:competition)
  end

  def load_results_for_competition
    @import_results = ImportResult.where(competition_id: @competition)
  end

  def filter_import_results_by_start_times
    @is_start_time = params[:is_start_times] || false
    @import_results = @import_results.where(is_start_time: @is_start_time)
  end

  def load_new_import_result
    @import_result = ImportResult.new(import_result_params)
    @import_result.user = @user
    @import_result.competition = @competition
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end
end
