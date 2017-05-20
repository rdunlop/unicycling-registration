class Translations::EventsController < Admin::TranslationsController
  before_action :load_event, except: :index

  def index
    @events = Event.all
  end

  # GET /translations/events/1/edit
  def edit; end

  # PUT /translations/events/1
  def update
    if @event.update_attributes(event_params)
      flash[:notice] = 'Event was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(translations_attributes: %i[id locale name])
  end
end
