class CompetitionSetup::EventConfigurationsController < ConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration
  before_action :set_breadcrumb

  load_and_authorize_resource

  def edit
  end

  def update
    @event_configuration.assign_attributes(event_configuration_params)
    if @event_configuration.save
      redirect_to competition_setup_path, notice: 'Event configuration was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_breadcrumb
    add_breadcrumb "Competition Setup", competition_setup_path
    add_breadcrumb "Edit Competition Settings"
  end

  def load_event_configuration
    @event_configuration = EventConfiguration.singleton
  end

  def event_configuration_params
    params.require(:event_configuration).permit(
      :artistic_score_elimination_mode_naucc,
      :max_award_place)
  end
end
