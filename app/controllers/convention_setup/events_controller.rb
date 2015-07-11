class ConventionSetup::EventsController < ConventionSetupController
  include SortableObject

  before_action :load_category, only: [:index, :create]
  before_action :authorize_setup
  before_action :set_categories_breadcrumb
  before_action :set_events_breadcrumb

  respond_to :html

  # GET /events
  # GET /events.json
  def index
    @events = @category.events.includes(:event_choices)
    @event = Event.new
    @event.event_categories.build

    respond_with(@events)
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = @category.events.build(event_params)
    respond_to do |format|
      if @event.save
        format.html { redirect_to convention_setup_category_events_path(@event.category), notice: 'Event was successfully created.' }
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
    respond_to do |format|
      if @event.update_attributes(event_params)
        format.html { redirect_to convention_setup_category_events_path(@event.category), notice: 'Event was successfully updated.' }
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
    params.require(:event).permit(:category_id, :name, :visible, :artistic, :accepts_music_uploads,
                                  :accepts_wheel_size_override,
                                  event_choices_attributes: [:cell_type, :label, :multiple_values, :id],
                                  event_categories_attributes: [:name, :id])
  end

  def load_category
    @category = Category.find(params[:category_id])
  end

  def load_new_event
    @event = @category.events.build(event_params)
  end
end
