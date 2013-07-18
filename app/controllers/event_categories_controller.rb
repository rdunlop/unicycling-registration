class EventCategoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_event, :only => [:index, :create]
  before_filter :load_event_category, :only => [:sign_ups, :freestyle_scores, :lock]

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_categories
    @event_categories = @event.event_categories
  end

  def load_event_category
    @event_category = EventCategory.find(params[:id])
  end

  # GET /event_categories
  # GET /event_categories.json
  def index
    load_categories
    @event_category = EventCategory.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_categories }
    end
  end

  # GET /event_categories/1
  # GET /event_categories/1.json
  def show
    @event_category = EventCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_category }
    end
  end

  # GET /event_categories/1/edit
  def edit
    @event_category = EventCategory.find(params[:id])
  end

  # POST /event_categories
  # POST /event_categories.json
  def create
    @event_category = EventCategory.new(params[:event_category])
    @event_category.event = @event

    respond_to do |format|
      if @event_category.save
        format.html { redirect_to event_event_categories_path(@event), notice: 'Event Category was successfully created.' }
        format.json { render json: @event_category, status: :created, location: event_event_categories_path(@event) }
      else
        load_categories
        format.html { render action: "index" }
        format.json { render json: @event_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_categories/1
  # PUT /event_categories/1.json
  def update
    @event_category = EventCategory.find(params[:id])

    respond_to do |format|
      if @event_category.update_attributes(params[:event_category])
        format.html { redirect_to @event_category, notice: 'Event Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_categories/1
  # DELETE /event_categories/1.json
  def destroy
    @event_category = EventCategory.find(params[:id])
    event = @event_category.event
    @event_category.destroy

    respond_to do |format|
      format.html { redirect_to event_event_categories_path(event) }
      format.json { head :no_content }
    end
  end

  def sign_ups
    @registrants = @event_category.signed_up_registrants
  end

  def freestyle_scores
  end

  def lock
    if request.post?
      @event_category.locked = true
    elsif request.delete?
      @event_category.locked = false
    end

    respond_to do |format|
      if @event_category.save
        format.html { redirect_to @event_category, notice: 'Updated lock status' }
      else
        format.html { redirect_to @event_category, notice: 'Unable to update lock status' }
      end
    end
  end
end

