# frozen_string_literal: true

class Exporters::Competition::SoloEventCompetitors
  attr_reader :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    ["ID", "LastName", "FirstName", "Country", "Gender", "Age Group"]
  end

  def rows
    registrants(@competition.id).map do |registrant|
      competitor = registrant.competitors.find { |c| c.competition_id == @competition.id }
      [
        registrant.bib_number,
        ActiveSupport::Inflector.transliterate(registrant.last_name),
        ActiveSupport::Inflector.transliterate(registrant.first_name),
        competitor.country,
        competitor.gender,
        competitor.age_group_entry_description
      ]
    end
  end

  private

  def registrants(competition_id)
    Registrant.active.competitor
              .joins(members: :competitor)
              .where(competitors: { competition_id: competition_id })
              .includes(competitors: :age_group_entry)
              .distinct
  end
end
