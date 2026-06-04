# Return a list of each competitor
# Example:
#
# ID Last First Country Gender Age-Group
# 698 Whitney Dergan Germany Female 30+
class Exporters::Competition::Simple
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    ["ID", "LastName", "FirstName", "Country", "Gender", "Age Group"]
  end

  def rows
    @competition.competitors.includes(:age_group_entry, members: [registrant: :contact_detail]).map do |competitor|
      if @competition.team_event?
        last_name = nil
        first_name = ActiveSupport::Inflector.transliterate(competitor.name)
      else
        last_name = ActiveSupport::Inflector.transliterate(competitor.registrants[0].last_name)
        first_name = ActiveSupport::Inflector.transliterate(competitor.registrants[0].first_name)
      end
      [
        competitor.bib_number,
        last_name,
        first_name,
        competitor.country,
        competitor.gender,
        competitor.age_group_entry_description
      ]
    end
  end
end
