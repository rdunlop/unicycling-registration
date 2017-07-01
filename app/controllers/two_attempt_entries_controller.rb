# == Schema Information
#
# Table name: two_attempt_entries
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  competition_id :integer
#  bib_number     :integer
#  minutes_1      :integer
#  minutes_2      :integer
#  seconds_1      :integer
#  status_1       :string(255)
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)
#  is_start_time  :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_two_attempt_entries_ids  (competition_id,is_start_time,id)
#

class TwoAttemptEntriesController < ApplicationController
  include IsStartTimeAction

  before_action :authenticate_user!
  before_action :load_user, only: %i[index create proof approve display_csv import_csv]
  before_action :load_competition, only: %i[index proof create approve display_csv import_csv]
  before_action :load_new_two_attempt_entry, only: [:create]
  before_action :set_is_start_time, only: %i[index proof approve display_csv import_csv]
  before_action :load_two_attempt_entries, only: %i[index proof approve display_csv]

  before_action :load_two_attempt_entry, only: %i[edit update destroy]
  before_action :authorize_data_entry, except: [:index]

  before_action :set_breadcrumbs

  # GET /users/#/two_attempt_entry
  # GET /users/#/two_attempt_entrys.json
  def index
    authorize @competition, :create_preliminary_result?

    add_breadcrumb "Add two-entry data"

    @two_attempt_entry = TwoAttemptEntry.new(is_start_time: @is_start_time)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @two_attempt_entry.update_attributes(two_attempt_entry_params)
        format.html { redirect_to user_competition_two_attempt_entries_path(@two_attempt_entry.user, @two_attempt_entry.competition, is_start_times: @two_attempt_entry.is_start_time), notice: 'Entry was successfully updated.' }
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
        # format.html { redirect_to user_competition_two_attempt_entries_path(@user, @competition), notice: 'Import result was successfully created.' }
        format.js { }
      else
        # index
        # @two_attempt_entries = TwoAttemptEntry.entries_for(@user, @competition, @is_start_time)
        # format.html { render action: "index" }
        format.js { }
      end
    end
  end

  # GET /users/#/competitions/#/two_attempt_entries/display_csv?is_start_times=true
  def display_csv
    add_breadcrumb "Import CSV"
  end

  # POST /users/#/competitions/#/two_attempt_entries/import_csv?is_start_times=true
  def import_csv
    importer = Importers::TwoAttemptEntryImporter.new(@competition, current_user)
    parser = if params[:advanced]
               Importers::Parsers::TwoAttemptSlalom.new(params[:file])
             else
               Importers::Parsers::TwoAttemptCsv.new(params[:file])
             end

    if importer.process(@is_start_time, parser)
      flash[:notice] = "Successfully imported #{importer.num_rows_processed} rows"
    else
      flash[:alert] = "Error importing rows. Errors: #{importer.errors}."
    end

    redirect_to display_csv_user_competition_two_attempt_entries_path(@user, @competition, is_start_times: @is_start_time)
  end

  def proof
    add_breadcrumb "Add two-entry data", user_competition_two_attempt_entries_path(@user, @competition, is_start_times: @is_start_time)
    add_breadcrumb "Proof"

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { render_common_pdf("proof") }
    end
  end

  def approve
    n = @two_attempt_entries.count
    begin
      TwoAttemptEntry.transaction do
        @two_attempt_entries.each do |ir|
          ir.import!
        end
        @two_attempt_entries.destroy_all
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

  def authorize_data_entry
    authorize @competition, :create_preliminary_result?
  end

  def load_user
    @user = User.this_tenant.find(params[:user_id])
  end

  def load_two_attempt_entry
    @two_attempt_entry = TwoAttemptEntry.find(params[:id])
    @competition = @two_attempt_entry.competition
  end

  def two_attempt_entry_params
    params.require(:two_attempt_entry).permit(:bib_number, :is_start_time,
                                              first_attempt: [*HoursFacade::PERMITTED_PARAMS, :status],
                                              second_attempt: [*HoursFacade::PERMITTED_PARAMS, :status])
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

  def load_two_attempt_entries
    @two_attempt_entries = TwoAttemptEntry.where(competition: @competition, is_start_time: @is_start_time).order(:id)
  end
end
