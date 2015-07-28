module FindsMatchingCompetitor
  extend ActiveSupport::Concern

  included do
  end

  def matching_registrant
    @maching_registrant ||= Registrant.find_by(bib_number: bib_number) if bib_number
  end

  def matching_competitor
    @matching_competitor ||= matching_registrant.competitors.active.find_by(competition: competition) if matching_registrant
  end

  def competitor_exists?
    matching_competitor.present?
  end

  def competitor_name
    matching_registrant
  end

  def competitor_has_results?
    matching_competitor.has_result? if competitor_exists?
  end

end
