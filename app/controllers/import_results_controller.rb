require 'upload'
class ImportResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, except: [:edit, :update, :destroy]
  before_action :load_competition, except: [:edit, :update, :destroy]
  before_action :load_import_result, only: [:edit, :update, :destroy]

  before_action :load_new_import_result, only: [:create]
  before_action :load_import_results, only: [:data_entry, :display_csv, :display_chip, :index]
  before_action :load_results_for_competition, only: [:review, :approve]
  before_action :filter_import_results_by_start_times, only: [:data_entry, :review, :approve]

  before_action :authorize_competition_data, except: [:approve]

  before_action :set_breadcrumbs

  # GET /users/#/competitions/#/import_results
  def index
    authorize @competition, :view_result_data?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_results }
    end
  end

  # GET /users/#/competitions/#/import_results/review
  def review
    add_breadcrumb "Review"
    @import_results = @import_results.entered_order
    respond_to do |format|
      format.html # review.html.erb
    end
  end

  # GET /import_results/1/edit
  def edit
    add_breadcrumb "Edit Imported Result"
  end

  # POST /users/#/competitions/#/import_results
  # POST /users/#/competitions/#/import_results.json
  def create
    respond_to do |format|
      if @import_result.save
        format.html { redirect_to data_entry_user_competition_import_results_path(@user, @competition, is_start_times: @import_result.is_start_time), notice: 'Result was successfully created.' }
        format.js { }
      else
        load_import_results
        filter_import_results_by_start_times
        format.html { render action: "data_entry" }
        format.js { }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update
    respond_to do |format|
      if @import_result.update_attributes(import_result_params)
        format.html { redirect_to data_entry_user_competition_import_results_path(@import_result.user, @import_result.competition, is_start_times: @import_result.is_start_time), notice: 'Import result was successfully updated.' }
        format.json { head :no_content }
        format.js { }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_result.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  # DELETE /import_results/1
  # DELETE /import_results/1.json
  def destroy
    @import_result.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  def data_entry
    add_breadcrumb "Enter Single Data"

    @import_result = ImportResult.new
    @import_result.is_start_time = @is_start_time
  end

  def display_chip
    add_breadcrumb "Import Chip Data"
  end

  def import_chip
    importer = RaceDataImporter.new(@competition, @user)

    if importer.process_chip(params[:file],
                             params[:bib_number_column_number].to_i - 1,
                             params[:time_column_number].to_i - 1,
                             params[:number_of_decimal_places].to_i,
                             params[:lap_column_number].to_i - 1)
      flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
    else
      flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
    end
    redirect_to display_chip_user_competition_import_results_path(@user, @competition)
  end

  def display_csv
    add_breadcrumb "Import CSV"
  end

  # POST /users/#/competitions/#/import_results/import_csv
  def import_csv
    importer = RaceDataImporter.new(@competition, @user)

    if importer.process_csv(params[:file], params[:start_times])
      flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
    else
      flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
    end
    redirect_to display_csv_user_competition_import_results_path(@user, @competition)
  end

  # DELETE /users/#/competitions/#/import_results/destroy_all
  def destroy_all
    @user.import_results.where(competition_id: @competition).destroy_all
    redirect_to :back
  end

  # POST /users/#/competitions/#/import_results/approve
  def approve
    authorize @competition, :create_preliminary_result?

    n = @import_results.count
    begin
      ImportResult.transaction do
        @import_results.each do |ir|
          ir.import!
        end
        @import_results.destroy_all
      end
    rescue Exception => ex
      errors = ex
    end

    respond_to do |format|
      if errors
        format.html { redirect_to :back, alert: "Errors: #{errors}" }
      else
        format.html { redirect_to :back, notice: "Added #{n} rows to #{@competition}." }
      end
    end
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
    @user = User.find(params[:user_id])
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
    @competition ||= @import_result.competition
    @user ||= @import_result.user
    add_to_competition_breadcrumb(@competition)
  end
end
