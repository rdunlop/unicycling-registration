# Return a list of competitors in a heat
# Example:
#
# <blank> ID Lane Last First Country
#   698 Whitney Dergan Germany
class Exporters::Competition::FinishLynx
  attr_accessor :competition, :heat

  def initialize(competition, heat)
    @competition = competition
    @heat = heat
  end

  def headers
    [competition.id, 1, heat, competition.to_s]
  end

  def rows
    lane_assignments = LaneAssignment.where(heat: heat, competition: @competition)
    lane_assignments.map do |lane_assignment|
      member = lane_assignment.competitor.active_members.first.registrant
      country = if member.country.nil?
                  nil
                else
                  ActiveSupport::Inflector.transliterate(member.country)
                end
      [
        nil,
        lane_assignment.competitor.lowest_member_bib_number,
        lane_assignment.lane,
        ActiveSupport::Inflector.transliterate(member.last_name),
        ActiveSupport::Inflector.transliterate(member.first_name),
        country
      ]
    end
  end
end
