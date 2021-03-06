class SwissResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user
  before_action :load_competition
  before_action :load_current_user_time_results

  before_action :authorize_competition_data

  before_action :set_breadcrumbs

  def index
    add_breadcrumb "Import Swiss Data"

    @previous_time_results = @competition.time_results.where(preliminary: false, competitor: @time_results.map(&:competitor), entered_by: current_user)

    @entered_heats = @competition.heat_lane_results.pluck(:heat).uniq.sort
  end

  def import
    uploaded_file = UploadedFile.process_params(params, competition: @competition, user: @user)
    if uploaded_file.nil?
      flash[:alert] = "Please specify a file"
    else
      parser = Importers::Parsers::Swiss.new(uploaded_file.original_file.file)
      importer = Importers::SwissResultImporter.new(@competition, @user)

      if importer.process(params[:heat], parser, heats: params[:heats] == "on")
        flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
      else
        flash[:alert] = "Error importing rows. Errors: #{importer.errors}"
      end
    end

    redirect_to user_competition_swiss_results_path(@user, @competition)
  end

  # DELETE /users/#/competitions/#/swiss_results/destroy_all
  def destroy_all
    @time_results.destroy_all
    redirect_back(fallback_location: user_competition_swiss_results_path(@user, @competition))
  end

  # # POST /users/#/competitions/#/swiss_results/approve
  def approve
    authorize @competition, :create_preliminary_result?

    n = @time_results.count
    begin
      TimeResult.transaction do
        @time_results.each do |time_result|
          time_result.preliminary = false
          time_result.save!
        end
      end
    rescue StandardError => e
      errors = e
    end

    if errors
      flash[:alert] = "Errors: #{errors}"
    else
      flash[:notice] = "Added #{n} rows to #{@competition}."
    end
    redirect_back(fallback_location: user_competition_swiss_results_path(@user, @competition))
  end

  def dq_single
    @time_result = TimeResult.find(params[:swiss_result_id])
    @time_result.status = "DQ"
    @time_result.status_description = params[:reason]
    if @time_result.save
      flash[:notice] = "Disqualified"
    else
      flash[:alert] = "Error marking as dq"
    end

    redirect_to user_competition_swiss_results_path(@user, @competition)
  end

  private

  def load_current_user_time_results
    @time_results = TimeResult.preliminary.where(entered_by: current_user)
  end

  def authorize_competition_data
    authorize @competition, :create_preliminary_result?
  end

  def load_user
    @user = User.this_tenant.find(params[:user_id])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_breadcrumbs
    @competition ||= @import_result.competition
    @user ||= @import_result.user
    add_to_competition_breadcrumb(@competition)
  end
end
