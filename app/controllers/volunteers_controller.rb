# This class supercedes the DataEntryVolunteers class
#
# Defines the abilities for a volunteer
class VolunteersController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition

  before_action :load_user, only: [:create, :destroy]
  before_action :load_and_validate_volunteer_type, only: [:create, :destroy]

  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage #{@competition} Volunteers", competition_volunteers_path(@competition)
  end

  # POST /competitions/#/volunteers/:volunteer_type
  # Allows setting of roles specific to a particular competition
  def create
    if @user.add_role(@volunteer_type, @competition)
      flash[:notice] = "#{@competition} #{@volunteer_type} was successfully created."
      redirect_to competition_volunteers_path(@competition)
    else
      flash.now[:alert] = "Error adding role"
      index
      render :index
    end
  end

  # DELETE
  def destroy
    if @user.remove_role(@volunteer_type, @competition)
      flash[:notice] = "#{@competition} #{@volunteer_type} was successfully removed."
      redirect_to competition_volunteers_path(@competition)
    else
      flash.now[:alert] = "Error removing role"
      index
      render :index
    end
  end

  private

  def load_user
    @user = User.this_tenant.find_by(id: params[:user_id])
    if @user.nil?
      flash[:alert] = "Please choose a user"
      redirect_back(fallback_location: competition_volunteers_path(@competition))
    end
  end

  # ensure that the given volunteer type is valid/allowed
  def load_and_validate_volunteer_type
    @volunteer_type = params[:volunteer_type]
    unless @competition.uses_volunteers.include?(@volunteer_type.to_sym)
      flash[:alert] = "Unsupported volunteer type"
      redirect_back(fallback_location: competition_volunteers_path(@competition))
    end
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def authorize_competition
    authorize @competition, :manage_volunteers?
  end
end
