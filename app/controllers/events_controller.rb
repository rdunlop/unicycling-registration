class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_category, :only => [:index, :create]
  before_filter :load_new_event, :only => [:create]
  load_and_authorize_resource

  before_action :set_breadcrumb, only: [:summary]

  respond_to :html

  # GET /events
  # GET /events.json
  def index
    @events = @category.events.includes(:event_choices)
    @event = Event.new
    @event.event_categories.build

    respond_with(@events)
  end

  # GET /events/summary
  def summary
    @num_male_competitors = Registrant.active.competitor.where({:gender => "Male"}).count
    @num_female_competitors = Registrant.active.competitor.where({:gender => "Female"}).count
    @num_competitors = @num_male_competitors + @num_female_competitors

    @num_male_noncompetitors = Registrant.active.notcompetitor.where({:gender => "Male"}).count
    @num_female_noncompetitors = Registrant.active.notcompetitor.where({:gender => "Female"}).count
    @num_noncompetitors = @num_male_noncompetitors + @num_female_noncompetitors

    @num_spectators = Registrant.active.spectator.count

    @num_male_registrants = @num_male_competitors + @num_male_noncompetitors
    @num_female_registrants = @num_female_competitors + @num_female_noncompetitors
    @num_registrants = @num_competitors + @num_noncompetitors + @num_spectators
  end

  def sign_ups
    add_category_breadcrumb(@event.category)
    add_event_breadcrumb(@event)
    add_breadcrumb "Sign Ups"
    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  # GET /events/1
  def show
    add_category_breadcrumb(@event.category)
    add_event_breadcrumb(@event)
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

  # POST /events/1/create_director
  def create_director
    user = User.find(params[:user_id])
    user.add_role(:director, @event)

    redirect_to event_path(@event), notice: 'Created Director'
  end

  # DELETE /events/1/destroy_director
  def destroy_director
    user = User.find(params[:user_id])
    user.remove_role(:director, @event)

    redirect_to event_path(@event), notice: 'Removed Director'
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

    respond_with(@event, location: category_events_path(@category))
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

  def set_breadcrumb
    add_breadcrumb "Events Report"
  end
end
