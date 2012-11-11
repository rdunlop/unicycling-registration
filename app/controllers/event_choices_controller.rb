class EventChoicesController < ApplicationController
  # GET /event_choices
  # GET /event_choices.json
  def index
    @event_choices = EventChoice.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_choices }
    end
  end

  # GET /event_choices/1
  # GET /event_choices/1.json
  def show
    @event_choice = EventChoice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_choice }
    end
  end

  # GET /event_choices/new
  # GET /event_choices/new.json
  def new
    @event_choice = EventChoice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_choice }
    end
  end

  # GET /event_choices/1/edit
  def edit
    @event_choice = EventChoice.find(params[:id])
  end

  # POST /event_choices
  # POST /event_choices.json
  def create
    @event_choice = EventChoice.new(params[:event_choice])

    respond_to do |format|
      if @event_choice.save
        format.html { redirect_to @event_choice, notice: 'Event choice was successfully created.' }
        format.json { render json: @event_choice, status: :created, location: @event_choice }
      else
        format.html { render action: "new" }
        format.json { render json: @event_choice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_choices/1
  # PUT /event_choices/1.json
  def update
    @event_choice = EventChoice.find(params[:id])

    respond_to do |format|
      if @event_choice.update_attributes(params[:event_choice])
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
    @event_choice = EventChoice.find(params[:id])
    @event_choice.destroy

    respond_to do |format|
      format.html { redirect_to event_choices_url }
      format.json { head :no_content }
    end
  end
end
