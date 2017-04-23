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
    @competition.competitors.map do |competitor|
      [
        competitor.bib_number,
        nil,
        ActiveSupport::Inflector.transliterate(competitor.name),
        competitor.country,
        competitor.gender,
        competitor.age_group_entry_description
      ]
    end
  end
end
