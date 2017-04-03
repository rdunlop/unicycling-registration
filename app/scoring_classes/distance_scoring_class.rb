class DistanceScoringClass < BaseScoringClass
  def scoring_description
    "A competitor can attempt repeatedly, scoring higher distances.
    Their last successful distance will be their final score.
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

  def competitor_dq?(competitor)
    return false unless competitor.has_attempt?
    !competitor.has_successful_attempt?
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "High/Long"
  end

  def scoring_path(judge)
    judge_distance_attempts_path(judge)
  end
end
