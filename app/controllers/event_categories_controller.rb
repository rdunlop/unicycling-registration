class EventCategoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_event, :only => [:index, :create]
  before_filter :load_event_category, :only => [:sign_ups]

  respond_to :html

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

    respond_with(@event_category)
  end

  # GET /event_categories/1
  # GET /event_categories/1.json
  def show

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

    respond_to do |format|
      if @event_category.update_attributes(event_category_params)
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
    event = @event_category.event
    @event_category.destroy

    respond_with(@event_category, location: event_event_categories_path(event))
  end

  def sign_ups
    add_category_breadcrumb(@event_category.event.category)
    add_breadcrumb "#{@event_category} Sign-Ups"

    respond_to do |format|
      format.html
      format.pdf { render :pdf => "show", :formats => [:html] }
    end
  end

  private
  def event_category_params
    params.require(:event_category).permit(:name, :position, :age_group_type_id, :age_range_start, :age_range_end)
  end
end

