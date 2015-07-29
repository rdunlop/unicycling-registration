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

end
