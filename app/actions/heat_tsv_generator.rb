# Return a list of each heat
# Example:
#
# nil nil 698 1 Durgan Whitney  Germany 30+ w
# nil nil 92  2 Crist Amely Italy 30+ w
# nil nil 543 3 Spinka Hank  Germany 30+ w
# nil nil 364 4 Larkin Cara Kornelia  Switzerland 30+ w
# nil nil 81  5 Hills Raegan  Italy 30+ w
# nil nil 498 6 Walter Yvette  Germany 30+ w
class HeatTsvGenerator
  attr_accessor :heat, :competition

  def initialize(competition, heat)
    @competition = competition
    @heat = heat
  end

  def generate
    csv_string = CSV.generate(col_sep: "\t") do |csv|
      data_rows.each do |row|
        csv << row
      end
    end

    csv_string
  end

  def data_rows
    rows = []
    lane_assignments = LaneAssignment.where(heat: heat, competition: competition)
    lane_assignments.each do |lane_assignment|
      competitor = lane_assignment.competitor
      rows << [
        nil,
        nil,
        competitor.lowest_member_bib_number,
        lane_assignment.lane,
        ActiveSupport::Inflector.transliterate(competitor.name),
        competitor.age_group_entry_description,
        competitor.gender
      ]
    end

    rows
  end
end
