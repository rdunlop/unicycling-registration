class ConventionSetup::EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_category, :only => [:index, :create]
  before_filter :load_new_event, :only => [:create]
  load_and_authorize_resource

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

  def event_params
    params.require(:event).permit(:category_id, :position, :name, :visible, :artistic, :accepts_music_uploads,
                                  :accepts_wheel_size_override,
                                  :event_choices_attributes => [:cell_type, :label, :multiple_values, :position, :id],
                                  :event_categories_attributes => [:name, :position, :id])
  end

  def load_category
    @category = Category.find(params[:category_id])
  end

  def load_new_event
    @event = @category.events.build(event_params)
  end
end
