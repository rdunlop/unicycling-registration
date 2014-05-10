require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  before_filter :authenticate_user!
  before_filter :load_new_competition, :only => [:create]

  before_filter :load_event, :only => [:index, :create, :new]
  before_filter :load_competitions, :only => [:index]

  load_and_authorize_resource

  respond_to :html


  private
  def load_new_competition
    @competition = Competition.new(competition_params)
    params[:id] = 1 if params[:id].nil? #necessary due to bug in the way that cancan does authorization check
  end

  def load_event
    @event = Event.find(params[:event_id])
    # required in order to set up the 'new' element
    @competition = Competition.new if @competition.nil?
    @competition.event = @event unless @competition.nil?
  end

  def load_competitions
    @competitions = @event.competitions
  end
  public

  # /events/#/competitions/new
  def new
    @competition.competition_sources.build
  end

  # GET /competitions
  # GET /competitions.json
  def index
    @competition = Competition.new
  end

  # GET /competitions/1/edit
  def edit
    @event = @competition.event
    3.times do
      @competition.competition_sources.build
    end
  end

  # POST /events/#/create
  def create

    if @competition.save
      flash[:notice] = "Competition created successfully"
    end

    respond_with(@competition, location: event_path(@competition.event))
  end

  # PUT /competitions/1
  # PUT /competitions/1.json
  def update
    if @competition.update_attributes(competition_params)
      flash[:notice] = 'Competition was successfully updated.'
    else
      @event = @competition.event
    end
    respond_with(@competition, location: event_path(@competition.event))
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

    respond_with(@competition, location: target_url)
  end

  def set_places
    @competition.scoring_helper.place_all
    redirect_to @competition.scoring_helper.results_path, :notice => "All Places updated"
  end

  def scores
    render @competition.render_path
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
        format.html { redirect_to event_path(@competition.event), notice: 'Updated lock status' }
      else
        format.html { redirect_to event_path(@competition.event), notice: 'Unable to update lock status' }
      end
    end
  end

  private
  def competition_params
    params.require(:competition).permit(:name, :locked, :age_group_type_id, :scoring_class, :has_experts, :has_age_groups,
                                        :competition_sources_attributes => [:id, :event_category_id, :gender_filter, :competition_id, :max_place, :_destroy])
  end
end

