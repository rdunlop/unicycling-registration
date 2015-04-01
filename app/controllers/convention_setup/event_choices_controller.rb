class ConventionSetup::EventChoicesController < ConventionSetupController
  include SortableObject

  before_action :authenticate_user!
  before_action :load_event, :only => [:index, :create]
  before_action :load_new_event_choice, :only => [:create]
  load_and_authorize_resource

  before_action :set_breadcrumbs

  respond_to :html

  # GET /event/1/event_choices
  # GET /event/1/event_choices.json
  def index
    load_choices
    @event_choice = EventChoice.new

    respond_with([:convention_setup, @event_choices])
  end

  # GET /event_choices/1/edit
  def edit
    @event_choices = @event_choice.event.event_choices - [@event_choice]
  end

  # POST /event/1/event_choices
  # POST /event/1/event_choices.json
  def create
    if @event_choice.save
      flash[:notice] = 'Event choice was successfully created.'
    else
      load_choices
    end
    respond_with(@event_choice, location: convention_setup_event_event_choices_path(@event), action: "index")
  end

  # PUT /event_choices/1
  # PUT /event_choices/1.json
  def update
    if @event_choice.update_attributes(event_choice_params)
      flash[:notice] = 'Event choice was successfully updated.'
    end
    respond_with(@event_choice, location: [:convention_setup, @event_choice], action: "edit")
  end

  # DELETE /event_choices/1
  # DELETE /event_choices/1.json
  def destroy
    event = @event_choice.event
    @event_choice.destroy

    respond_with(@event_choice, location: convention_setup_event_event_choices_path(event))
  end

  private

  def sortable_object
    EventChoice.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb "Event Categories", convention_setup_categories_path
    add_breadcrumb "#{@event.category} Events", convention_setup_event_path(@event) if @event
    add_breadcrumb "Event Choices", convention_setup_event_event_choices_path(@event) if @event
  end

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_new_event_choice
    @event_choice = @event.event_choices.new(event_choice_params)
  end

  def load_choices
    @event_choices = @event.event_choices
  end

  def event_choice_params
    params.require(:event_choice).permit(:cell_type, :label, :multiple_values, :autocomplete, :optional, :tooltip,
                                         :optional_if_event_choice_id, :required_if_event_choice_id,
                                         :translations_attributes => [:id, :label, :tooltip, :locale])
  end
end
