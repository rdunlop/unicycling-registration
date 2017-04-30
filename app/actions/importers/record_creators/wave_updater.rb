class Importers::RecordCreators::WaveUpdater
  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def save(row_hash, _row)
    competitor = @competition.competitors.where(lowest_member_bib_number: row_hash[:bib_number]).first
    raise "Unable to find competitor #{bib_number}" if competitor.nil?
    competitor.update_attribute(:wave, row_hash[:wave])
  end
end
