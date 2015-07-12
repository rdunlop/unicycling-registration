require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition

  authorize_resource only: [:publish_age_group_entry, :set_age_group_places]

  before_action :add_competition_setup_breadcrumb, only: [:show, :set_sort]

  respond_to :html, :js

  def show
    authorize @competition
    add_breadcrumb "#{@competition}"
  end

  def set_sort
    authorize @competition, :sort?
    add_breadcrumb "#{@competition}", competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition)
    add_breadcrumb "Sort Competitors"
  end

  def toggle_final_sort
    authorize @competition, :sort?

    new_value = !@competition.order_finalized?

    if new_value
      flash[:notice] = "Sort Order finalized"
    else
      flash[:alert] = "Sort Order Marked non-final"
    end

    @competition.update_attribute(:order_finalized, new_value)
    redirect_to set_sort_competition_path(@competition)
  end

  def sort_random
    authorize @competition, :sort?

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
      @competition.place_age_group_entry(age_group_entry)
      flash[:notice] = "All Places updated for #{age_group_entry}"
    end
    redirect_to result_competition_path(@competition)
  end

  def set_places
    authorize @competition

    @competition.place_all
    Result.update_last_calc_places_time(@competition)
    redirect_to result_competition_path(@competition), notice: "All Places updated"
  end

  def result
    authorize @competition
    @anonymous = params[:anonymous].present?
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Result", result_competition_path(@competition)
    render @competition.render_path
  end

  def export_scores
    authorize @competition
    if @competition.event_class == 'High/Long'
      csv_string = CSV.generate do |csv|
        csv << ['registrant_external_id', 'distance']
        @competition.competitors.each do |comp|
          if comp.has_result?
            csv << [comp.export_id,
                    comp.result]
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
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  def lock
    authorize @competition
    respond_to do |format|
      if CompetitionStateMachine.new(@competition).lock
        format.html { redirect_to @competition, notice: 'Locked Competition' }
      else
        format.html { redirect_to @competition, alert: 'Unable to lock competition' }
      end
    end
  end

  def unlock
    authorize @competition

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
    authorize @competition

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
    authorize @competition
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
    authorize @competition
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

  def load_competition
    @competition = Competition.find(params[:id])
  end
end
