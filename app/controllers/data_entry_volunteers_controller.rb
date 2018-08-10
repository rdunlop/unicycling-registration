class DataEntryVolunteersController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition

  before_action :load_new_data_entry_volunteer, only: :index

  respond_to :html

  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Additional UDA Access", competition_data_entry_volunteers_path(@competition)

    @all_data_entry_volunteers = User.this_tenant.data_entry_volunteer

    @events = Event.all
  end

  # POST /competitions/#/data_entry_volunteers
  # POST /competitions/#/data_entry_volunteers.json
  def create
    @data_entry_volunteer = DataEntryVolunteer.new(params[:data_entry_volunteer])
    if @data_entry_volunteer.save
      flash[:notice] = 'Additional UDA Access was successfully created.'
    else
      index
    end
    respond_with(@data_entry_volunteer, location: competition_data_entry_volunteers_path(@competition), action: "index")
  end

  # DELETE /competitions/#/data_entry_volunteers/:user_id
  def destroy
    @data_entry_volunteer = DataEntryVolunteer.new(user_id: params[:user_id])
    if @data_entry_volunteer.destroy
      flash[:notice] = 'Additional UDA Access was successfully removed.'
    else
      flash[:alert] = "Unable to remove data entry volunteer"
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
