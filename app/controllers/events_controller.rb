class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_category, :only => [:index, :create]
  before_filter :load_new_event, :only => [:create]
  load_and_authorize_resource

  respond_to :html

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

    respond_with(@events)
  end

  # GET /events/summary
  def summary
    @num_male_competitors = Registrant.where({:competitor => true, :gender => "Male"}).count
    @num_female_competitors = Registrant.where({:competitor => true, :gender => "Female"}).count
    @num_competitors = @num_male_competitors + @num_female_competitors
    @num_male_noncompetitors = Registrant.where({:competitor => false, :gender => "Male"}).count
    @num_female_noncompetitors = Registrant.where({:competitor => false, :gender => "Female"}).count
    @num_noncompetitors = @num_male_noncompetitors + @num_female_noncompetitors

    @num_male_registrants = @num_male_competitors + @num_male_noncompetitors
    @num_female_registrants = @num_female_competitors + @num_female_noncompetitors
    @num_registrants = @num_competitors + @num_noncompetitors
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

  # POST /events/1/create_chief
  def create_chief
    user = User.find(params[:user_id])
    user.add_role(:chief_judge, @event)

    redirect_to event_path(@event), notice: 'Created Chief Judge'
  end

  # DELETE /events/1/destroy_chief
  def destroy_chief
    user = User.find(params[:user_id])
    user.remove_role(:chief_judge, @event)

    redirect_to event_path(@event), notice: 'Removed Chief Judge'
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

  def judging
    @judges = current_user.judges
  end

  private
  def event_params
    params.require(:event).permit(:category_id, :export_name, :position, :name, :visible, :accepts_music_uploads,
                                  :event_choices_attributes => [:export_name, :cell_type, :label, :multiple_values, :position, :id],
                                  :event_categories_attributes => [:name, :position, :id])
  end
end
