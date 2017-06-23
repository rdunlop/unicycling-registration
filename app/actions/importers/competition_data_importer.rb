class Importers::CompetitionDataImporter < Importers::BaseImporter
  attr_accessor :competition

  def initialize(competition, user)
    super(user)
    @competition = competition
  end
end
