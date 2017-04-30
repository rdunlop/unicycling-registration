class Importers::RecordCreators::PreliminaryExternalResult
  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def save(row_hash, _)
    build_and_save_imported_result(row_hash, @user, @competition)
  end

  private

  # from CSV to import_result
  def build_and_save_imported_result(row_hash, user, competition)
    ExternalResult.preliminary.create!(
      competitor: CompetitorFinder.new(competition).find_by_bib_number(row_hash[:bib_number]),
      points: row_hash[:points],
      details: row_hash[:details],
      status: row_hash[:status],
      entered_at: DateTime.current,
      entered_by: user)
  end
end
