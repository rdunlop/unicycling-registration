# == Schema Information
#
# Table name: competitions
#
#  id                            :integer          not null, primary key
#  event_id                      :integer
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  age_group_type_id             :integer
#  has_experts                   :boolean          default(FALSE), not null
#  scoring_class                 :string(255)
#  start_data_type               :string(255)
#  end_data_type                 :string(255)
#  uses_lane_assignments         :boolean          default(FALSE), not null
#  scheduled_completion_at       :datetime
#  awarded                       :boolean          default(FALSE), not null
#  award_title_name              :string(255)
#  award_subtitle_name           :string(255)
#  num_members_per_competitor    :string(255)
#  automatic_competitor_creation :boolean          default(FALSE), not null
#  combined_competition_id       :integer
#  order_finalized               :boolean          default(FALSE), not null
#  penalty_seconds               :integer
#  locked_at                     :datetime
#  published_at                  :datetime
#  sign_in_list_enabled          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  include EventsHelper
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition

  before_action :add_competition_setup_breadcrumb, only: [:show, :set_sort]

  respond_to :html, :js

  def show
    authorize @competition
    add_breadcrumb @competition.to_s
  end

  def set_sort
    authorize @competition, :sort?
    add_breadcrumb @competition.to_s, competition_path(@competition)
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
    authorize @competition

    if params[:age_group_entry_id].empty?
      flash[:alert] = "You must specify an age group entry"
    else
      age_group_entry = AgeGroupEntry.find(params[:age_group_entry_id])
      @competition.place_age_group_entry(age_group_entry)
      flash[:notice] = "All Places updated for #{age_group_entry}"
    end
    redirect_to :back
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
        csv << %w(judge_id judge_type_id registrant_external_id val1 val2 val3 val4)
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

  def export_times
    authorize @competition
    if @competition.event_class == 'Shortest Time'
      csv_string = CSV.generate do |csv|
        csv << %w(registrant_external_id gender age heat lane thousands result)
        @competition.competitors.each do |comp|
          if comp.has_result?
            tr = comp.time_results.first
            heat = tr.heat_lane_result

            csv << [comp.export_id,
                    comp.gender,
                    comp.age,
                    heat.try(:heat),
                    heat.try(:lane),
                    comp.best_time_in_thousands,
                    comp.result]
          end
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
    authorize @competition

    publisher = CompetitionStateMachine.new(@competition)
    entry = params[:age_group_entry]

    if publisher.publish_age_group_entry(entry)
      flash[:notice] = 'Published Competition Age Group Entry'
    else
      flash[:alert] = 'Unable to publish competition age group entry'
    end
    redirect_to :back
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
    if request.post?
      authorize @competition, :award?
      @competition.awarded = true
    elsif request.delete?
      authorize @competition, :unaward?
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

  # Delete all the result data for this competition.
  # Note: only works for Time Results and External Results....
  # (Judged events do not work).
  def destroy_all_results
    authorize @competition

    results = @competition.scoring_helper.all_competitor_results
    if results.present?
      Competition.transaction do
        results.each(&:destroy)
      end
      flash[:notice] = "Deleted all data for this competition"
    else
      flash[:alert] = "No results to be deleted"
    end

    redirect_to @competition
  end

  private

  def load_competition
    @competition = Competition.find(params[:id])
  end
end
