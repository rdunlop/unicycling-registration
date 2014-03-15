class EventChoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_event, :only => [:index, :create]
  before_filter :load_new_event_choice, :only => [:create]
  load_and_authorize_resource

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_new_event_choice
    @event_choice = @event.event_choices.new(event_choice_params)
  end

  def load_choices
    @event_choices = @event.event_choices
  end

  # GET /event/1/event_choices
  # GET /event/1/event_choices.json
  def index
    load_choices
    @event_choice = EventChoice.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_choices }
    end
  end

  # GET /event_choices/1
  # GET /event_choices/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_choice }
    end
  end

  # GET /event_choices/1/edit
  def edit
    @event_choices = @event_choice.event.event_choices - [@event_choice]
  end

  # POST /event/1/event_choices
  # POST /event/1/event_choices.json
  def create

    respond_to do |format|
      if @event_choice.save
        format.html { redirect_to event_event_choices_path(@event), notice: 'Event choice was successfully created.' }
        format.json { render json: @event_choice, status: :created, location: event_event_choices_path(@event) }
      else
        load_choices
        format.html { render action: "index" }
        format.json { render json: @event_choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_choices/1
  # PUT /event_choices/1.json
  def update

    respond_to do |format|
      if @event_choice.update_attributes(event_choice_params)
        format.html { redirect_to @event_choice, notice: 'Event choice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_choices/1
  # DELETE /event_choices/1.json
  def destroy
    event = @event_choice.event
    @event_choice.destroy

    respond_to do |format|
      format.html { redirect_to event_event_choices_path(event) }
      format.json { head :no_content }
    end
  end

  private
  def event_choice_params
    params.require(:event_choice).permit(:cell_type, :export_name, :label, :multiple_values, :position, :autocomplete, :optional, :tooltip,
                                         :optional_if_event_choice_id, :required_if_event_choice_id,
                                         :translations_attributes => [:id, :label, :tooltip, :locale])
  end
end
