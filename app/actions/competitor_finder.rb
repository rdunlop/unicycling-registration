class CompetitorFinder
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  # Returns a Competitor, or raises an exception
  def find_by(bib_number:)
    registrant = Registrant.find_by!(bib_number: bib_number)
    registrant.competitors.find_by!(competition: competition)
  end
end
