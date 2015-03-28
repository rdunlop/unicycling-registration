class Translations::EventConfigurationsController < ConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration
  load_and_authorize_resource

  def edit
  end

  def update
    @event_configuration.assign_attributes(translation_attributes)
    if @event_configuration.save
      flash[:notice] = "Successfully updated translations"
      redirect_to action: :edit
    else
      render :edit
    end
  end

  def load_event_configuration
    @event_configuration = EventConfiguration.singleton
  end

  def translation_attributes
    params.require(:event_configuration).permit(translations_attributes: [
                                                  :id, :locale, :short_name, :long_name, :location, :dates_description,
                                                  :competitor_benefits, :noncompetitor_benefits, :spectator_benefits])
  end
end
