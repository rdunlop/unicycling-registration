class CompetitionSetup::DirectorsController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :authorize_director_management

  def index
    @events = Event.order(:name).all
  end

  # POST /directors/
  def create
    params[:users_id].each do |user_id|
      user = User.this_tenant.find(user_id)
      params[:events_id].each do |event_id|
        event = Event.find(event_id)
        user.add_role(:director, event)
      end
    end

    redirect_to directors_path, notice: 'Created Director(s)'
  end

  # DELETE /directors/:id/
  def destroy
    user = User.this_tenant.find(params[:id])
    event = Event.find(params[:event_id])
    user.remove_role(:director, event)

    redirect_to directors_path, notice: 'Removed Director'
  end

  private

  def authorize_director_management
    authorize @config, :setup_competition?
  end
end
