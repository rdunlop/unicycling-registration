class EventsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def load_category
    @category = Category.find(params[:category_id])
  end

  # GET /events
  # GET /events.json
  def index
    load_category
    @events = @category.events
    @event = Event.new
    @event.event_categories.build

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    load_category
    @event = @category.events.build(params[:event])

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
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
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
    @event = Event.find(params[:id])
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

  def judging
    @judges = current_user.judges
  end
end
