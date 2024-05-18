module FindsMatchingCompetitor
  extend ActiveSupport::Concern

  included do
  end

  def matching_registrant
    @matching_registrant ||= FindCompetitorForCompetition.new(bib_number, nil).registrant if bib_number
  end

  def matching_competitor
    @matching_competitor ||= FindCompetitorForCompetition.new(bib_number, competition).competitor
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
