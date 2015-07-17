class DataEntryVolunteersController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition

  before_action :load_new_data_entry_volunteer, only: :index

  respond_to :html

  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Data Entry Volunteers", competition_data_entry_volunteers_path(@competition)

    @all_data_entry_volunteers = User.with_role(:data_entry_volunteer).order(:email)

    @events = Event.all
  end

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    @data_entry_volunteer = DataEntryVolunteer.new(params[:data_entry_volunteer])
    if @data_entry_volunteer.save
      flash[:notice] = 'Data Entry Volunteer was successfully created.'
    else
      index
    end
    respond_with(@data_entry_volunteer, location: competition_data_entry_volunteers_path(@competition), action: "index")
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_data_entry_volunteer
    @data_entry_volunteer = DataEntryVolunteer.new
  end

  def authorize_competition
    authorize @competition, :manage_volunteers?
  end
end
