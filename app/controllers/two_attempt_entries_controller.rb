class TwoAttemptEntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user
  before_filter :load_competition, :only => [:index, :proof, :create, :approve]
  before_filter :load_new_two_attempt_entry, :only => [:create]
  before_action :set_is_start_time, only: [:index, :proof, :approve]
  load_and_authorize_resource

  before_action :set_breadcrumbs

  # GET /users/#/two_attempt_entry
  # GET /users/#/two_attempt_entrys.json
  def index
    add_breadcrumb "Add two-entry data"

    @two_attempt_entries = TwoAttemptEntry.where(user: @user, competition: @competition, is_start_time: @is_start_time)
    @two_attempt_entry = TwoAttemptEntry.new(is_start_time: @is_start_time)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @two_attempt_entry.update_attributes(two_attempt_entry_params)
        format.html { redirect_to user_competition_two_attempt_entries_path(@two_attempt_entry.user, @two_attempt_entry.competition, is_start_times: @two_attempt_entry.is_start_time), notice: 'Two attemp entry was successfully updated.' }
        format.json { head :no_content }
        format.js { }
      else
        format.html { render action: "edit" }
        format.json { render json: @two_attempt_entry.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  def destroy
    user = @two_attempt_entry.user
    competition = @two_attempt_entry.competition
    @two_attempt_entry.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
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
    add_breadcrumb "Add two-entry data", user_competition_two_attempt_entries_path(@user, @competition, is_start_times: @is_start_time)
    add_breadcrumb "Proof"


    @two_attempt_entries = TwoAttemptEntry.where(:competition_id => @competition, is_start_time: @is_start_time)

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { render_common_pdf("proof") }
    end
  end

  def approve
    two_attempt_entries = TwoAttemptEntry.where(:competition_id => @competition, is_start_time: @is_start_time)

    n = two_attempt_entries.count
    begin
      TwoAttemptEntry.transaction do
        two_attempt_entries.each do |ir|
          ir.import!
        end
        two_attempt_entries.destroy_all
      end
    rescue Exception => ex
      errors = ex
    end

    respond_to do |format|
      if errors
        format.html { redirect_to :back, alert: "Errors: #{errors}" }
      else
        format.html { redirect_to result_competition_path(@competition), notice: "Added #{n} rows to #{@competition}." }
      end
    end
  end

  private

  def two_attempt_entry_params
    params.require(:two_attempt_entry).permit(:bib_number, :is_start_time,
      :status_1, :minutes_1, :seconds_1, :thousands_1,
      :status_2, :minutes_2, :seconds_2, :thousands_2)
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
  end

  def set_is_start_time
    @is_start_time = params[:is_start_times] && params[:is_start_times] == "true"
  end
end

