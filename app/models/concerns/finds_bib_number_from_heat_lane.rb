# Requires that the included class provide:
# competition
# heat
# lane
module FindsBibNumberFromHeatLane
  extend ActiveSupport::Concern

  # returns a bib number, or 0 if no lane assignment is found
  def bib_number
    get_id_from_lane_assignment(competition, heat, lane) || 0
  end

  private

  def get_id_from_lane_assignment(comp, heat, lane)
    la = LaneAssignment.find_by(competition: comp, heat: heat, lane: lane)
    if la.nil?
      id = nil
    else
      id = la.competitor.first_bib_number
    end
    id
  end
end
