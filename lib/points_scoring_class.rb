class PointsScoringClass < BaseScoringClass

  attr_accessor :lower_is_better

  def initialize(competition, lower_is_better = true)
    super(competition)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "Externally scored competition results are entered, in which the points
    of competitors is entered, and a 'details' column, which is a description of the result
    (for use on the awards/results sheets). #{lower_is_better ? 'Lower' : 'Higher'} points are better"
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    OrderedResultCalculator.new(@competition, lower_is_better)
  end

  # describes how to label the results of this competition
  def result_description
    "Score"
  end

  def render_path
    "external_results"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.external_results.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.external_results.first.try(:details)
    else
      nil
    end
  end

  def competitor_comparable_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.external_results.first.points
    else
      0
    end
  end

  def competitor_dq?(competitor)
    false
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.external_results
  end

  def uses_judges
    false
  end

  # from import_result to external_result
  def build_result_from_imported(import_result)
    ExternalResult.new(
      points: import_result.rank,
      details: import_result.details)
  end

  # from CSV to import_result
  def build_import_result_from_raw(raw)
    ImportResult.new(
      bib_number: raw[0],
      rank: raw[1],
      details: raw[2])
  end
end
