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
  def merge
    heat_lane_result = competition.heat_lane_results.find_by(heat: heat, lane: lane)
    time_result = heat_lane_result.try(:time_result)
    if time_result
      time_result.update_attributes(status: "DQ", comments: comments, comments_by: entered_by)
      return true
    else
      return false
    end
  end
end
