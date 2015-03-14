class ConventionSetup::EventCategoriesController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :load_event, :only => [:index, :create]
  before_action :set_breadcrumbs

  respond_to :html

  # GET /event_categories
  # GET /event_categories.json
  def index
    load_categories
    @event_category = EventCategory.new

    respond_with([:convention_setup, @event_category])
  end

  # GET /event_categories/1/edit
  def edit
  end

  # POST /event_categories
  # POST /event_categories.json
  def create
    @event_category.event = @event

    respond_to do |format|
      if @event_category.save
        format.html { redirect_to convention_setup_event_event_categories_path(@event), notice: 'Event Category was successfully created.' }
      else
        load_categories
        format.html { render action: "index" }
      end
    end
  end

  # PUT /event_categories/1
  # PUT /event_categories/1.json
  def update
    respond_to do |format|
      if @event_category.update_attributes(event_category_params)
        format.html { redirect_to convention_setup_event_event_categories_path(@event_category.event), notice: 'Event Category was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /event_categories/1
  # DELETE /event_categories/1.json
  def destroy
    event = @event_category.event
    @event_category.destroy

    respond_with(@event_category, location: convention_setup_event_event_categories_path(event))
  end

  private

  def set_breadcrumbs
    add_breadcrumb "Event Categories", convention_setup_categories_path
    add_breadcrumb "#{@event.category} Events", convention_setup_category_events_path(@event.category) if @event
    add_breadcrumb "Event Categories", convention_setup_event_event_categories_path(@event) if @event
  end

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_categories
    @event_categories = @event.event_categories
  end

  def event_category_params
    params.require(:event_category).permit(:name, :warning_on_registration_summary, :position, :age_group_type_id, :age_range_start, :age_range_end)
  end
end

