class Translations::EventChoicesController < Admin::TranslationsController
  before_action :authenticate_user!
  load_resource

  def index
    @event_choices = EventChoice.all
  end

  # GET /translations/event_choices/1/edit
  def edit
  end

  # PUT /translations/event_choices/1
  def update
    if @event_choice.update_attributes(event_choice_params)
      flash[:notice] = 'EventChoice was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def event_choice_params
    params.require(:event_choice).permit(translations_attributes: [:id, :locale, :label, :tooltip])
  end
end
