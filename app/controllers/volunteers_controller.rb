# This class supercedes the DataEntryVolunteers class
#
# Defines the abilities for a volunteer
class VolunteersController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition

  before_action :validate_volunteer_type, only: [:create, :destroy]

  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage #{@competition} Volunteers", competition_volunteers_path(@competition)
  end

  # POST /competitions/#/volunteers/:volunteer_type
  # Allows setting of roles specific to a particular competition
  def create
    unless params[:user_id].present?
      flash[:alert] = "Please choose a user"
      redirect_to :back
      return
    end

    @user = User.find(params[:user_id])
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
    @user = User.find(params[:user_id])
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

  # ensure that the given volunteer type is valid/allowed
  def validate_volunteer_type
    @volunteer_type = params[:volunteer_type]
    @volunteer_type == "race_official"
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def authorize_competition
    authorize @competition, :manage_volunteers?
  end
end
