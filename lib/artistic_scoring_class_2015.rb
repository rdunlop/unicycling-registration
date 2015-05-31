class ArtisticScoringClass_2015 < BaseScoringClass
  def scoring_description
    "Using the Freestyle scoring rules, multiple Performance and Technical judges
    will score each competitor, and then the resulting points (converted to percentage of points) will be used to
    calculate the winner. As per the IUF 2015 Rulebook"
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    ArtisticScoreCalculator_2015.new(@competition)
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
    competitor.scores.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      nil# not applicable in Freestyle
    else
      nil
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
    nil
  end

  def uses_judges
    true
  end

  def scoring_path(judge)
    judge_scores_path(judge)
  end

  def compete_in_order?
    true
  end

  def requires_age_groups
    false
  end

  def can_eliminate_judges?
    true
  end
end
