class ConventionSetup::EventChoicesController < ConventionSetup::BaseConventionSetupController
  include SortableObject

  before_action :load_event, only: %i[index create]
  before_action :load_event_choice, except: %i[index create]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /event/1/event_choices
  # GET /event/1/event_choices.json
  def index
    load_choices
    @event_choice = EventChoice.new
  end

  # GET /event_choices/1/edit
  def edit
    @event_choices = @event_choice.event.event_choices - [@event_choice]
  end

  # POST /event/1/event_choices
  # POST /event/1/event_choices.json
  def create
    @event_choice = @event.event_choices.new(event_choice_params)
    if @event_choice.save
      flash[:notice] = 'Event choice was successfully created.'
      redirect_to convention_setup_event_event_choices_path(@event)
    else
      load_choices
      render :index
    end
  end

  # PUT /event_choices/1
  # PUT /event_choices/1.json
  def update
    if @event_choice.update_attributes(event_choice_params)
      flash[:notice] = 'Event choice was successfully updated.'
      redirect_to [:convention_setup, @event_choice.event, :event_choices]
    else
      edit
      render :edit
    end
  end

  # DELETE /event_choices/1
  # DELETE /event_choices/1.json
  def destroy
    event = @event_choice.event
    @event_choice.destroy

    redirect_to convention_setup_event_event_choices_path(event)
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def sortable_object
    EventChoice.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb "Event Categories", convention_setup_categories_path
    add_breadcrumb "#{@event.category} Events", convention_setup_category_events_path(@event.category) if @event
    add_breadcrumb "Event Choices", convention_setup_event_event_choices_path(@event) if @event
  end

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_choices
    @event_choices = @event.event_choices
  end

  def load_event_choice
    @event_choice = EventChoice.find(params[:id])
  end

  def event_choice_params
    params.require(:event_choice).permit(:cell_type, :label, :multiple_values, :optional, :tooltip,
                                         :optional_if_event_choice_id, :required_if_event_choice_id,
                                         translations_attributes: %i[id label tooltip locale])
  end
end
