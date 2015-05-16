require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  layout "competition_management", except: :new

  before_action :authenticate_user!
  before_action :load_new_competition, :only => [:create]
  before_action :load_competition, except: [:create, :new]

  before_action :load_event_from_competition, only: [:edit]
  before_action :load_event, :only => [:create, :new]

  load_and_authorize_resource

  before_action :add_competition_setup_breadcrumb, only: [:new, :edit, :show, :set_sort]

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

  # POST /competitions/#/create
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

  # DELETE /competitions/1
  # DELETE /competitions/1.json
  def destroy
    target_url = event_path(@competition.event)
    @competition.destroy

    respond_with(@competition, location: target_url)
  end

  def set_sort
    add_breadcrumb "#{@competition}", competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition)
    add_breadcrumb "Sort Competitors"
  end

  def toggle_final_sort
    new_value = !@competition.order_finalized

    if new_value
      flash[:notice] = "Sort Order finalized"
    else
      flash[:alert] = "Sort Order Marked non-final"
    end

    @competition.update_attribute(:order_finalized, new_value)
    redirect_to set_sort_competition_path(@competition)
  end

  def sort_random
    @competitors = @competition.competitors
    @competitors.shuffle.each_with_index do |comp, index|
      # reload or else the acts_as_restful_list positioning gets screwed up
      comp.reload.position = index + 1
      comp.save!
    end
    flash[:notice] = "Shuffled Competitor sort order"

    redirect_to set_sort_competition_path(@competition)
  end

  def set_age_group_places
    if params[:age_group_entry_id].empty?
      flash[:alert] = "You must specify an age group entry"
    else
      age_group_entry = AgeGroupEntry.find(params[:age_group_entry_id])
      @competition.scoring_helper.place_age_group_entry(age_group_entry)
      flash[:notice] = "All Places updated for #{age_group_entry}"
    end
    redirect_to result_competition_path(@competition)
  end

  def set_places
    @competition.scoring_helper.place_all
    Result.update_last_calc_places_time(@competition)
    redirect_to result_competition_path(@competition), :notice => "All Places updated"
  end

  def result
    @anonymous = params[:anonymous].present?
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Result", result_competition_path(@competition)
    render @competition.render_path
  end

  def export_scores
    if @competition.event_class == 'High/Long'
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
    respond_to do |format|
      if CompetitionStateMachine.new(@competition).lock
        format.html { redirect_to @competition, notice: 'Locked Competition' }
      else
        format.html { redirect_to @competition, alert: 'Unable to lock competition' }
      end
    end
  end

  def unlock
    respond_to do |format|
      if CompetitionStateMachine.new(@competition).unlock
        format.html { redirect_to @competition, notice: 'UnLocked Competition' }
      else
        format.html { redirect_to @competition, alert: 'Unable to unlock competition' }
      end
    end
  end

  def publish_age_group_entry
    publisher = CompetitionStateMachine.new(@competition)
    entry = params[:age_group_entry]

    respond_to do |format|
      if publisher.publish_age_group_entry(entry)
        format.html { redirect_to @competition, notice: 'Published Competition Age Group Entry' }
      else
        format.html { redirect_to @competition, alert: 'Unable to publish competition age group entry' }
      end
    end
  end

  def publish
    publisher = CompetitionStateMachine.new(@competition)

    respond_to do |format|
      if publisher.publish
        format.html { redirect_to @competition, notice: 'Published Competition' }
      else
        format.html { redirect_to @competition, alert: 'Unable to publish competition' }
      end
    end
  end

  def unpublish
    publisher = CompetitionStateMachine.new(@competition)

    respond_to do |format|
      if publisher.unpublish
        format.html { redirect_to @competition, notice: 'Unpublished Competition' }
      else
        format.html { redirect_to @competition, alert: 'Unable to unpublish Competition' }
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
                                        :award_subtitle_name, :scheduled_completion_at, :num_members_per_competitor,
                                        :penalty_seconds, :automatic_competitor_creation, :combined_competition_id,
                                        :competition_sources_attributes => [:id, :event_category_id, :gender_filter, :min_age, :max_age, :competition_id, :max_place, :_destroy],
                                        :heat_times_attributes => [:id, :scheduled_time, :heat, :minutes, :seconds, :_destroy] )
  end

  def load_competition
    @competition = Competition.find(params[:id])
  end

  def load_new_competition
    @competition = Competition.new(competition_params)
    params[:id] = 1 if params[:id].nil? # necessary due to bug in the way that cancan does authorization check
  end

  def load_event_from_competition
    @event ||= @competition.event
  end

  def load_event
    @event = Event.find(params[:event_id])
    # required in order to set up the 'new' element
    @competition = Competition.new if @competition.nil?
    @competition.event = @event unless @competition.nil?
  end
end
