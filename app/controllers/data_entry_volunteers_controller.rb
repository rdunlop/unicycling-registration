class DataEntryVolunteersController < ApplicationController
  layout "competition_management"

  load_and_authorize_resource :competition
  before_action :load_new_data_entry_volunteer, only: :index

  respond_to :html

  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Data Entry Volunteers", competition_data_entry_volunteers_path(@competition)

    @all_data_entry_volunteers = User.with_role(:data_entry_volunteer).order(:email)
    @race_officials = User.with_role(:race_official).order(:email)

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

  def load_new_data_entry_volunteer
    @data_entry_volunteer = DataEntryVolunteer.new
  end
end
