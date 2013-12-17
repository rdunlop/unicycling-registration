class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_category, :only => [:index, :create]
  before_filter :load_new_event, :only => [:create]
  load_and_authorize_resource

  def load_category
    @category = Category.find(params[:category_id])
  end

  def load_new_event
    @event = @category.events.build(event_params)
  end

  # GET /events
  # GET /events.json
  def index
    @events = @category.events
    @event = Event.new
    @event.event_categories.build

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  def show
  end
  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create

    respond_to do |format|
      if @event.save
        format.html { redirect_to category_events_path(@event.category), notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: category_events_path(@event.category) }
      else
        load_category
        @events = @category.events
        format.html { render action: "index" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update

    respond_to do |format|
      if @event.update_attributes(event_params)
        format.html { redirect_to category_events_path(@event.category), notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @category = @event.category
    @event.destroy

    respond_to do |format|
      format.html { redirect_to category_events_path(@category) }
      format.json { head :no_content }
    end
  end

  def freestyle
    @events = Event.where({:event_class => "Freestyle"})
  end

  def flatland
    @events = Event.where({:event_class => "Flatland"})
  end

  def street
    @events = Event.where({:event_class => "Street"})
  end

  def track
    @events = Event.where({:event_class => "Two Attempt Distance"})
  end

  def distance
    @events = Event.where({:event_class => "Distance"})
  end

  def ranked
    @events = Event.where({:event_class => "Ranked"})
  end

  def judging
    @judges = current_user.judges
  end

  private
  def event_params
    params.require(:event).permit(:category_id, :export_name, :position, :name, :event_class, :visible,
                                  :event_choices_attributes => [:export_name, :cell_type, :label, :multiple_values, :position, :id], 
                                  :event_categories_attributes => [:name, :position, :id])
  end
end
