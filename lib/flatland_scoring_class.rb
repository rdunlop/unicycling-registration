class FlatlandScoringClass < BaseScoringClass
  def scoring_description
    "A variation of the Artistic Scoring Class, we calculate last-trick
    scores and follow the rulebook (or do we?)"
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    FlatlandScoreCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "freestyle_scores"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    false
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      nil # not applicable in Freestyle
    else
      nil
    end
  end

  # Function which places all of the competitors in the competition
  def place_all
    nil
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    true
  end

  def include_event_name
    true
  end

  def requires_age_groups
    false
  end
end
