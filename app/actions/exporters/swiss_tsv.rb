# Return a list of each heat
# Example:
#
# nil nil 698 1 Durgan Whitney  Germany 30+ w
# nil nil 92  2 Crist Amely Italy 30+ w
# nil nil 543 3 Spinka Hank  Germany 30+ w
# nil nil 364 4 Larkin Cara Kornelia  Switzerland 30+ w
# nil nil 81  5 Hills Raegan  Italy 30+ w
# nil nil 498 6 Walter Yvette  Germany 30+ w
class Exporters::SwissTsv
  attr_accessor :heat, :competition

  def initialize(competition, heat)
    @competition = competition
    @heat = heat
  end

  def headers
    nil
  end

  def rows
    if heat.nil?
      all_competitor_rows
    else
      lane_assignment_rows
    end
  end

  private

  def all_competitor_rows
    competition.competitors.map do |competitor|
      row(competitor, nil)
    end
  end

  def lane_assignment_rows
    lane_assignments = LaneAssignment.where(heat: heat, competition: competition)
    lane_assignments.map do |lane_assignment|
      competitor = lane_assignment.competitor
      row(competitor, lane_assignment.lane)
    end
  end

  def row(competitor, lane)
    [
      nil,
      nil,
      competitor.lowest_member_bib_number,
      lane,
      ActiveSupport::Inflector.transliterate(competitor.name),
      competitor.age_group_entry_description,
      competitor.gender
    ]
  end
end
