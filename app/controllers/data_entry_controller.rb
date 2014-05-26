class DataEntryController < ApplicationController
  before_filter :authenticate_user!
  before_action :load_competition#, except: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :user
  before_filter :load_new_import_result, :only => [:create_single]
  load_resource :import_result, except: [:single, :show]
  authorize_resource class: false

  before_action :load_import_results, :only => :single

  before_action :set_breadcrumbs

  # GET /users/#/competitions/#/single_attempt_entries
  def single
    add_breadcrumb "Enter Single Data"

    @is_start_time = params[:is_start_times] || false
    @import_result = ImportResult.new
    @import_result.is_start_time = @is_start_time

    @import_results = @import_results.where(is_start_time: @is_start_time)
  end

  # GET /import_results/1/edit
  def edit_single
    add_breadcrumb "Edit Single Result"
  end

  # POST /users/#/competitions/#/import_results
  # POST /users/#/competitions/#/import_results.json
  def create_single
#    @import_result = ImportResult.new(import_result_params)

    respond_to do |format|
      if @import_result.save
        format.html { redirect_to user_competition_single_attempt_entries_path_path(@user, @competition), notice: 'Import result was successfully created.' }
        format.js { }
      else
        @import_results = @user.import_results
        format.html { render action: "single" }
        format.js { }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update_single
    @import_result = ImportResult.find(params[:id])

    respond_to do |format|
      if @import_result.update_attributes(import_result_params)
        format.html { redirect_to user_competition_import_results_path(@import_result.user, @import_result.competition), notice: 'Import result was successfully updated.' }
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
  def destroy_single
    user = @import_result.user
    competition = @import_result.competition
    @import_result.destroy

    respond_to do |format|
      format.html { redirect_to user_competition_import_results_path(user, competition) }
      format.json { head :no_content }
    end
  end

  # DELETE /users/#/competitions/#/import_results/destroy_all
  def destroy_all
    @user.import_results.where(:competition_id => @competition).destroy_all
    redirect_to user_competition_import_results_path(@user, @competition)
  end

  private

  def import_result_params
    params.require(:import_result).permit(:bib_number, :disqualified, :minutes, :raw_data, :seconds, :thousands, :rank, :details, :is_start_time)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_import_results
    @import_results = @user.import_results.where(competition_id: @competition)
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
    add_breadcrumb "Import Results (#{@user})", user_competition_import_results_path(@user, @competition)
  end
end

