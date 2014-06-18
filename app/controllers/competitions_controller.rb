require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  before_filter :authenticate_user!
  before_filter :load_new_competition, :only => [:create]

  before_filter :load_event, :only => [:create, :new]

  load_and_authorize_resource

  before_action :set_parent_breadcrumbs, only: [:new, :edit, :show]

  respond_to :html, :js

  # /events/#/competitions/new
  def new
    add_breadcrumb "New Competition"

    @competition.competition_sources.build
  end

  # GET /competitions/1/edit
  def edit
    add_breadcrumb "Edit Competition"
  end

  def show
    add_breadcrumb "#{@competition}"
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

  def sort
    @competitors = @competition.competitors
    @competitors.each do |comp|
      comp.position = params['competitor'].index(comp.id.to_s) + 1
      comp.save
    end
    respond_with(@competition)
  end

  def sort_random
    @competitors = @competition.competitors
    @competitors.shuffle.each_with_index do |comp, index|
      comp.position = index + 1
      comp.save
    end
    flash[:notice] = "Shuffled Competitor sort order"

    redirect_to new_competition_competitor_path(@competition)
  end

  def set_places
    @competition.scoring_helper.place_all
    redirect_to @competition.scoring_helper.results_path, :notice => "All Places updated"
  end

  def result
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Result", result_competition_path(@competition)
    render @competition.render_path
  end

  def export_scores
    if @competition.event_class == 'Two Attempt Distance'
      csv_string = CSV.generate do |csv|
        csv << ['registrant_external_id', 'distance']
        @competition.competitors.each do |comp|
          da = comp.max_successful_distance
          if da != 0
            csv << [comp.export_id,
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
        format.html { redirect_to @competition, alert: 'Unable to update lock status' }
      end
    end
  end

  def publish
    creator = CreatesCompetitionResultsPdf.new(@competition)

    if request.post?
      creator.publish!
      @competition.published = true
    elsif request.delete?
      creator.unpublish!
      @competition.published = false
    end

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: 'Updated publish status' }
      else
        format.html { redirect_to @competition, alert: 'Unable to update publish status' }
      end
    end
  end

  def award
    if request.post?
      @competition.awarded = true
    elsif request.delete?
      @competition.awarded = false
    end

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: 'Updated awarded status' }
      else
        format.html { redirect_to @competition, alert: 'Unable to update awarded status' }
      end
    end
  end

  private

  def competition_params
    params.require(:competition).permit(:name, :uses_lane_assignments, :start_data_type, :end_data_type,
                                        :age_group_type_id, :scoring_class, :has_experts, :award_title_name,
                                        :award_subtitle_name, :scheduled_completion_at,
                                        :competition_sources_attributes => [:id, :event_category_id, :gender_filter, :min_age, :max_age, :competition_id, :max_place, :_destroy])
  end

  def set_parent_breadcrumbs
    @event ||= @competition.event
    add_category_breadcrumb(@event.category)
    add_event_breadcrumb(@event)
  end

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

end
