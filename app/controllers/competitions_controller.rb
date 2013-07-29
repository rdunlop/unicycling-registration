require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_event, :only => [:index, :create_empty, :new_empty]
  before_filter :load_event_category, :only => [:create, :new]
  before_filter :load_competition, :only => [:sign_ups, :freestyle_scores, :street_scores, :lock, :set_places]

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

  def new_empty
    @competition = Competition.new
  end

  # POST /events/#/create_empty
  def create_empty
    @competition = Competition.new
    @competition.name = params[:name]
    @competition.has_experts = params[:has_experts]
    @competition.has_age_groups = params[:has_age_groups]
    @competition.age_group_type_id = params[:age_group_type_id]
    @competition.event = @event

    respond_to do |format|
      if @competition.save
        format.html { redirect_to judging_menu_url(@competition), notice: "Competition created successfully" }
      else
        # XXX???
        format.html { redirect_to judging_menu_url(@competition), notice: "ERROR creating competition" }
      end
    end
  end

  # POST /event_categories/#/competitions
  # POST /event_categories/#/competitions.json
  def create
    @competition = Competition.new(params[:competition])
    @competition.event = @event_category.event

    @event_category.competition = @competition

    @gender_filter = params[:gender_filter]
    registrants = @event_category.signed_up_registrants
    unless @gender_filter.nil? or @gender_filter == "Both"
      registrants = registrants.select {|reg| reg.gender == @gender_filter}
    end

    registrants = registrants.shuffle

    respond_to do |format|
      if @event_category.valid? and @competition.save
        @event_category.save
        message = "Competition was successfully created."

        message += @competition.create_competitors_from_registrants(registrants)

        if @event_category.event_class == "Distance"
          format.html { redirect_to distance_events_path, notice:  message }
        else
          format.html { redirect_to competition_competitors_path(@competition), notice:  message }
        end
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
    target_url = judging_menu_url(@competition)
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to target_url }
      format.json { head :no_content }
    end
  end

  def distance_attempts
    @distance_attempts = @competition.best_distance_attempts
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def set_places
    if @competition.event.event_class == "Distance"
      @calc = @competition.score_calculator
      @calc.update_all_places
      redirect_to competition_time_results_path(@competition), :notice => "All Places updated"
    elsif @competition.event.event_class == "Two Attempt Distance"
      @calc = @competition.score_calculator
      @calc.update_all_places
      redirect_to distance_attempts_competition_path(@competition), :notice => "All Places Updated"
    elsif @competition.event.event_class == "Ranked"
      @calc = @competition.score_calculator
      @calc.update_all_places
      redirect_to competition_external_results_path(@competition), :notice => "All Places Updated"
    end
  end

  def freestyle_scores
  end

  def street_scores
  end

  def export_scores
    if @competition.event.event_class == 'Two Attempt Distance'
      csv_string = CSV.generate do |csv|
        csv << ['registrant_external_id', 'distance']
        @competition.competitors.each do |comp|
          da = comp.max_successful_distance
          if da != 0
            csv << [comp.external_id,
              da]
          end
        end
      end
    else
      csv_string = CSV.generate do |csv|
        csv << ['judge_id', 'judge_type_id', 'registrant_external_id', 'val1', 'val2', 'val3', 'val4']
        @competition.scores.each do |score|
          csv << [score.judge.external_id,
            score.judge.judge_type.name,
            score.competitor.export_id, # use a single value even in groups
            score.val_1,
            score.val_2,
            score.val_3,
            score.val_4]
        end
      end
    end
    filename = @competition.name.downcase.gsub(/[^0-9a-z]/, "_") + ".csv"
    send_data(csv_string,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
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

