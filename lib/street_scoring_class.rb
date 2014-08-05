class StreetScoringClass < BaseScoringClass

  def scoring_description
    "A varation of the artistic scoring, for use in street comp"
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    StreetCompScoreCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "street_scores"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    false
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      nil# not applicable in Freestyle
    else
      nil
    end
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

  def competitor_dq?(competitor)
    false
  end

  def requires_age_groups
    false
  end

  def compete_in_order
    true
  end
end
