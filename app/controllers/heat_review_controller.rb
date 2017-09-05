class HeatReviewController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition
  before_action :load_heat, except: :index
  before_action :authorize_competition_data

  before_action :set_breadcrumbs

  # GET /competitions/#/heat_review/
  def index
    @min_heat = LaneAssignment.where(competition: @competition).minimum(:heat) || 0
    @max_heat = LaneAssignment.where(competition: @competition).maximum(:heat) || 0
  end

  # GET /competitions/#/heat_review/:heat/
  def show
    @lane_assignments = LaneAssignment.where(competition: @competition, heat: @heat)
    @heat_lane_results = HeatLaneResult.where(competition: @competition, heat: @heat)
    @heat_lane_judge_notes = HeatLaneJudgeNote.where(competition: @competition, heat: @heat)
    @time_results = @competition.time_results.joins(:heat_lane_result).merge(HeatLaneResult.heat(@heat))

    respond_to do |format|
      format.html
    end
  end

  # FOR LIF (track racing) data:
  # POST /competitions/#/heat_review/:heat/import_lif
  def import_lif
    unless @competition.uses_lane_assignments?
      flash[:alert] = "Competition not set for lane assignments"
      redirect_to competition_heat_review_path(@competition, @heat)
      return
    end

    uploaded_file = UploadedFile.process_params(params, competition: @competition, user: current_user)

    if uploaded_file.nil?
      flash[:alert] = "Please specify a file"
      redirect_to competition_heat_review_path(@competition, @heat)
      return
    end

    parser = Importers::Parsers::Lif.new(uploaded_file.original_file.file)
    importer = Importers::HeatLaneLifImporter.new(@competition, current_user)

    if importer.process(@heat, parser)
      flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
    else
      flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
    end
    redirect_to competition_heat_review_path(@competition, @heat)
  end

  # POST /competitions/#/heat_review/:heat/approve_heat
  def approve_heat
    authorize @competition, :create_preliminary_result?

    heat_lane_results = HeatLaneResult.where(competition_id: @competition, heat: @heat)

    begin
      HeatLaneResult.transaction do
        heat_lane_results.each do |hlr|
          hlr.import!
        end
      end
    rescue Exception => ex
      errors = ex
    end

    respond_to do |format|
      if errors
        format.html { redirect_to :back, alert: "Errors: #{errors}" }
      else
        format.html { redirect_to competition_heat_review_path(@competition, @heat), notice: "Added Heat # #{@heat} results" }
      end
    end
  end

  # DELETE /competitions/#/heat_review/:heat
  def destroy
    heat_lane_results = HeatLaneResult.where(competition_id: @competition, heat: @heat)
    heat_lane_results.destroy_all

    redirect_to competition_heat_review_path(@competition, @heat), notice: "deleted Heat # #{@heat} results. Try Again?"
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

  def load_heat
    @heat = params[:heat].to_i
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
