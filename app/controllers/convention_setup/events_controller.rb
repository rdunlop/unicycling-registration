class ConventionSetup::EventsController < ConventionSetup::BaseConventionSetupController
  include SortableObject

  before_action :load_category, only: %i[index create]
  before_action :load_event, except: %i[index create]
  before_action :authorize_setup
  before_action :set_categories_breadcrumb
  before_action :set_events_breadcrumb

  respond_to :html

  # GET /events
  # GET /events.json
  def index
    @events = @category.events.includes(:event_choices)
    @form = EventForm.new(Event.new)
    @form.event_categories.build

    respond_with(@events)
  end

  # GET /events/1/edit
  def edit
    @form = EventForm.new(@event)
    @form.cost = @event.expense_item.cost if @event.expense_item
  end

  # POST /events
  # POST /events.json
  def create
    event = @category.events.build
    @form = EventForm.new(event)
    @form.assign_attributes(event_params)
    respond_to do |format|
      if @form.save
        format.html { redirect_to convention_setup_category_events_path(@form.category), notice: 'Event was successfully created.' }
      else
        load_category
        @events = @category.events
        format.html { render action: "index" }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @form = EventForm.new(@event)
    @form.assign_attributes(event_params)
    respond_to do |format|
      if @form.save
        format.html { redirect_to convention_setup_category_events_path(@form.category), notice: 'Event was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @category = @event.category
    @event.destroy

    respond_with(@event, location: convention_setup_category_events_path(@category))
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def sortable_object
    Event.find(params[:id])
  end

  def set_events_breadcrumb
    add_breadcrumb "#{@category} Events", convention_setup_category_events_path(@category) if @category
  end

  def event_params
    params.require(:event).permit(:category_id, :name, :cost, :visible, :artistic, :accepts_music_uploads,
                                  :accepts_wheel_size_override, :best_time_format, :standard_skill,
                                  event_choices_attributes: %i[cell_type label multiple_values id],
                                  event_categories_attributes: %i[name id])
  end

  def load_category
    @category = Category.find(params[:category_id])
  end

  def load_event
    @event = Event.find(params[:id])
  end
end
