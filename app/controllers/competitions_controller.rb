class CompetitionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_event, :only => [:index]
  before_filter :load_event_category, :only => [:create, :new]
  before_filter :load_competition, :only => [:sign_ups, :freestyle_scores, :lock]

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_competitions
    @competitions = @event.competitions
  end

  def load_event_category
    @event_category = EventCategory.find(params[:event_category_id])
  end

  def load_competition
    @competition = Competition.find(params[:id])
  end

  # /event_categories/#/competitions/new
  def new
  end

  # GET /competitions
  # GET /competitions.json
  def index
    load_competitions
    @competition = Competition.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @competitions }
    end
  end

  # GET /competitions/1
  # GET /competitions/1.json
  def show
    @competition = Competition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @competition }
    end
  end

  # GET /competitions/1/edit
  def edit
    @competition = Competition.find(params[:id])
  end

  # POST /event_categories/#/competitions
  # POST /event_categories/#/competitions.json
  def create
    @competition = Competition.new(params[:competition])
    @competition.event = @event_category.event

    @event_category.competition = @competition

    respond_to do |format|
      if @event_category.valid? and @competition.save
        @event_category.save
        message = "Competition was successfully created."

        message += @competition.create_competitors_from_registrants(@event_category.signed_up_registrants)

        format.html { redirect_to competition_competitors_path(@competition), notice:  message }
        format.json { render json: @competition, status: :created, location: competition_competitors_path(@event) }
      else
        load_event_category
        format.html { render action: "new" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /competitions/1
  # PUT /competitions/1.json
  def update
    @competition = Competition.find(params[:id])

    respond_to do |format|
      if @competition.update_attributes(params[:competition])
        format.html { redirect_to @competition, notice: 'Competition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1
  # DELETE /competitions/1.json
  def destroy
    @competition = Competition.find(params[:id])
    event = @competition.event
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to event_competitions_path(event) }
      format.json { head :no_content }
    end
  end

  def freestyle_scores
  end

  def lock
    if request.post?
      @competition.locked = true
    elsif request.delete?
      @competition.locked = false
    end

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: 'Updated lock status' }
      else
        format.html { redirect_to @competition, notice: 'Unable to update lock status' }
      end
    end
  end
end

