class ExternallyRankedScoringClass < BaseScoringClass

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    OrderedResultCalculator.new(@competition)
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
    competitor.external_results.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.external_results.first.try(:details)
    else
      nil
    end
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end

  def ordered_results
    @competition.external_results.includes(:competitor).order("rank")
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.external_results
  end

  # the page where all of the results for this competition are listed
  def results_path
    scores_competition_path(I18n.locale, @competition)
  end

  def results_importable
    true
  end

  def uses_judges
    false
  end
end
