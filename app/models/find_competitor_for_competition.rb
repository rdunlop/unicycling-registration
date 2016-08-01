class FindCompetitorForCompetition
  attr_accessor :bib_number, :competition

  def initialize(bib_number, competition)
    @bib_number = bib_number
    @competition = competition
  end

  def registrant
    @registrant ||= Registrant.find_by(bib_number: bib_number) if bib_number
  end

  def competitor
    @competitor ||= registrant.competitors.active.find_by(competition: competition) if registrant
  end

  def competitor_exists?
    competitor.present?
  end

  def competitor_name
    registrant
  end

  def competitor_has_results?
    competitor.has_result? if competitor_exists?
  end
end
