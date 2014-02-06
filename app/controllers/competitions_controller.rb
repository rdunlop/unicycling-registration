require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  before_filter :authenticate_user!
  before_filter :load_new_competition, :only => [:create]

  before_filter :load_event, :only => [:index, :create, :new]
  before_filter :load_competitions, :only => [:index]

  load_and_authorize_resource

  def load_new_competition
    @competition = Competition.new(competition_params)
    params[:id] = 1 if params[:id].nil? #necessary due to bug in the way that cancan does authorization check
  end

  def load_event
    @event = Event.find(params[:event_id])
    # required in order to set up the 'new' element
    @competition.event = @event unless @competition.nil?
  end

  def load_competitions
    @competitions = @event.competitions
  end

  # /events/#/competitions/new
  def new
  end

  # GET /competitions
  # GET /competitions.json
  def index
    @competition = Competition.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @competitions }
    end
  end

  # GET /competitions/1
  # GET /competitions/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @competition }
    end
  end

  # GET /competitions/1/edit
  def edit
    @event = @competition.event
  end

  # POST /events/#/create
  def create
    respond_to do |format|
      if @competition.save
        format.html { redirect_to event_path(@competition.event), notice: "Competition created successfully" }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /competitions/#/populate
  def populate
    gender_filter = @competition.gender_filter
    registrants = @competition.event.signed_up_registrants
    unless gender_filter.nil? or gender_filter == "Both"
      registrants = registrants.select {|reg| reg.gender == gender_filter}
    end

    registrants = registrants.shuffle

    respond_to do |format|
      message = @competition.create_competitors_from_registrants(registrants)

      format.html { redirect_to event_path(@competition.event), notice:  message }
      format.json { render json: @competition, status: :created, location: competition_competitors_path(@event) }
    end
  end

  # PUT /competitions/1
  # PUT /competitions/1.json
  def update
    respond_to do |format|
      if @competition.update_attributes(competition_params)
        format.html { redirect_to @competition, notice: 'Competition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1/destroy_results
  def destroy_results
    @results = nil
    @results = @competition.scoring_helper.all_competitor_results

    n = 0
    err = 0
    @results.each do |res|
      if res.destroy
        n += 1
      else
        err += 1
      end
    end
    respond_to do |format|
      format.html { redirect_to results_url(@competition), notice: "#{n} records deleted. #{err} errors" }
    end
  end

  # DELETE /competitions/1
  # DELETE /competitions/1.json
  def destroy
    target_url = event_path(@competition.event)
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
    @competition.scoring_helper.place_all
    redirect_to @competition.scoring_helper.results_path, :notice => "All Places updated"
  end

  def freestyle_scores
  end

  def street_scores
  end

  def export_scores
    if @competition.event_class == 'Two Attempt Distance'
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

  private
  def competition_params
    params.require(:competition).permit(:name, :locked, :age_group_type_id, :scoring_class, :has_experts, :has_age_groups, :gender_filter)
  end
end

