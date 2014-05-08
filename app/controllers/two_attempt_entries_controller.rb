class TwoAttemptEntriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user, :only => [:index, :create, :data_entry, :import_csv, :import_lif, :publish_to_competition, :destroy_all]
  before_filter :load_competition, :only => [:index, :create, :data_entry, :import_csv, :import_lif, :publish_to_competition, :destroy_all]
  before_filter :load_new_two_attempt_entry, :only => [:create]
  skip_authorization_check
  #load_and_authorize_resource

  private
  def load_user
    @user = User.find(params[:user_id])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_two_attempt_entry
    @two_attempt_entry = TwoAttemptEntry.new(two_attempt_entry_params)
    @two_attempt_entry.user = @user
    @two_attempt_entry.competition = @competition
  end

  public
  # GET /users/#/import_results
  # GET /users/#/import_results.json
  def index
    @two_attempt_entries = [] #@user.import_results.where(:competition_id => @competition)
    @two_attempt_entry = TwoAttemptEntry.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_results }
    end
  end

  # GET /import_results/1
  # GET /import_results/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import_result }
    end
  end

  # GET /import_results/1/edit
  def edit
  end

  # POST /users/#/competitions/#/import_results
  # POST /users/#/competitions/#/import_results.json
  def create

    respond_to do |format|
      if @two_attempt_entry.save
        format.html { redirect_to user_competition_two_attempt_entries_path(@user, @competition), notice: 'Import result was successfully created.' }
        format.js { }
      else
        @import_results = @user.import_results
        format.html { render action: "index" }
        format.js { }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update

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
  def destroy
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

  def two_attempt_entry_params
    params.require(:two_attempt_entry).permit(:bib_number, :is_start_time,
      :dq_1, :raw_data_1, :minutes_1, :seconds_1, :thousands_1,
      :dq_2, :raw_data_2, :minutes_2, :seconds_2, :thousands_2)
  end
end

