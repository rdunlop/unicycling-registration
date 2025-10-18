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

    mismatching_names = []
    uploaded_files.each do |file|
      heat = Importers::HeatFromFilenameExtractor.extract_heat(file.filename)
      if heat.nil?
        mismatching_names << file.filename
      end
    end

    unless mismatching_names.empty?
      error_message = if mismatching_names.length < 10
                        "Error importing rows. The following file(s) do not finish with '{dd}.lif' ('{dd}' being any integer): #{mismatching_names.join(', ')}."
                      else
                        "Error importing rows. #{mismatching_names.length} files do not finish with '{dd}.lif' ('{dd}' being any integer)."
                      end
      flash[:alert] = error_message
      redirect_to competition_multiple_heat_review_index_path(@competition)
      return
    end

    num_rows_processed = 0
    errors = []
    uploaded_files.each do |file|
      parser = Importers::Parsers::Lif.new(file.original_file.file)
      importer = Importers::HeatLaneLifImporter.new(@competition, current_user)

      # Extracting the heat from the filename
      filename = file.original_file.filename
      heat = Importers::HeatFromFilenameExtractor.extract_heat(filename)

      if importer.process(heat, parser)
        num_rows_processed += importer.num_rows_processed
      else
        errors.push([filename, importer.errors])
      end
    end

    unless num_rows_processed == 0
      flash[:notice] = "Successfully imported #{num_rows_processed} rows"
    end
    unless errors.empty?
      errors = errors.map { |error| "File '#{error[0]}': #{error[1]}" }.join("; ")
      flash[:alert] = "Error importing rows. Errors: #{errors}."
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

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end
end
