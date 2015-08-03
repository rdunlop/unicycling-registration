# == Schema Information
#
# Table name: heat_lane_judge_notes
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  comments       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_heat_lane_judge_notes_on_competition_id  (competition_id)
#

class HeatLaneJudgeNote < ActiveRecord::Base
  include TracksEnteredBy
  include FindsMatchingCompetitor
  include FindsBibNumberFromHeatLane

  validates :competition_id, presence: true
  validates :heat, :lane, :status, presence: true

  validates :status, inclusion: { in: TimeResult.status_values }

  belongs_to :competition, inverse_of: :heat_lane_judge_notes

  def disqualified?
    status == "DQ"
  end

  def to_s
    (comments || "") + " - by #{entered_by}"
  end

  # Set these results into the final Time Results table
  # creates a new time_result if one doesn't exist
  def merge
    heat_lane_result = competition.heat_lane_results.find_by(heat: heat, lane: lane)
    time_result = heat_lane_result.try(:time_result)
    if time_result
      time_result.update_attributes(status: "DQ", comments: comments, comments_by: entered_by)
      true
    else
      competitor = heat_lane_result.matching_competitor
      time_result = competitor.time_results.build(
        minutes: 0,
        seconds: 0,
        thousands: 0,
        status: "DQ",
        comments: comments,
        comments_by: entered_by,
        entered_by: heat_lane_result.entered_by,
        entered_at: heat_lane_result.entered_at,
        preliminary: false,
        heat_lane_result: heat_lane_result
      )
      time_result.save
    end
  end
end
