class TwoAttemptEntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user
  before_filter :load_competition, :only => [:index, :proof, :create]
  before_filter :load_new_two_attempt_entry, :only => [:create]
  load_and_authorize_resource

  before_action :set_breadcrumbs

  # GET /users/#/two_attempt_entry
  # GET /users/#/two_attempt_entrys.json
  def index
    add_breadcrumb "Add two-entry data"

    @is_start_time = !params[:is_start_times].blank?

    @two_attempt_entries = TwoAttemptEntry.entries_for(@user, @competition, @is_start_time)
    @two_attempt_entry = TwoAttemptEntry.new(is_start_time: @is_start_time)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # POST /users/#/competitions/#/two_attempt_entries
  # POST /users/#/competitions/#/two_attempt_entries.json
  def create

    respond_to do |format|
      if @two_attempt_entry.save
        #format.html { redirect_to user_competition_two_attempt_entries_path(@user, @competition), notice: 'Import result was successfully created.' }
        format.js { }
      else
        #index
        #@two_attempt_entries = TwoAttemptEntry.entries_for(@user, @competition, @is_start_time)
        #format.html { render action: "index" }
        format.js { }
      end
    end
  end

  def proof
    @is_start_time = !params[:is_start_times].blank?

    @two_attempt_entries = TwoAttemptEntry.entries_for(@user, @competition, @is_start_time)

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { render_common_pdf("proof") }
    end
  end

  private

  def two_attempt_entry_params
    params.require(:two_attempt_entry).permit(:bib_number, :is_start_time,
      :dq_1, :minutes_1, :seconds_1, :thousands_1,
      :dq_2, :minutes_2, :seconds_2, :thousands_2)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_two_attempt_entry
    @two_attempt_entry = TwoAttemptEntry.new(two_attempt_entry_params)
    @two_attempt_entry.user = @user
    @two_attempt_entry.competition = @competition
  end

  def set_breadcrumbs
    @competition ||= @two_attempt_entry.competition
    @user ||= @two_attempt_entry.user
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Import Results", user_competition_import_results_path(@user, @competition)
  end
end

