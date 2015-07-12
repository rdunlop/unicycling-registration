class CompetitionSetup::DirectorsController < ApplicationController
  before_action :authorize_director_management

  def index
    @events = Event.order(:name).all
  end

  # POST /directors/
  def create
    user = User.find(params[:user_id])
    event = Event.find(params[:event_id])
    user.add_role(:director, event)

    redirect_to directors_path, notice: 'Created Director'
  end

  # DELETE /directors/:id/
  def destroy
    user = User.find(params[:id])
    event = Event.find(params[:event_id])
    user.remove_role(:director, event)

    redirect_to directors_path(event), notice: 'Removed Director'
  end

  private

  def authorize_director_management
    authorize @config, :setup_competition?
  end
end
