class DistanceScoringClass < BaseScoringClass
  def scoring_description
    "Å competitor can attempt repeatedly, scoring higher distances. Eventually the competitor
    will double-fault, and their last successful distance will be their final score.
    The competitor with the highest max distance will win."
  end

  def lower_is_better
    false
  end

  # describes how to label the results of this competition
  def result_description
    "Distance"
  end

  def example_result
    "10 cm"
  end

  def render_path
    "distance_attempts"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.distance_attempts.any?
  end

  def imports_times
    true
  end

  def competitor_dq?(competitor)
    return false if competitor.best_distance_attempt.nil?
    competitor.best_distance_attempt.fault?
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    true
  end

  def scoring_path(judge)
    judge_distance_attempts_path(judge)
  end
end
