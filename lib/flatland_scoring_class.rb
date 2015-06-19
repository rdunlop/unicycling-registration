class FlatlandScoringClass < BaseScoringClass
  def scoring_description
    "A variation of the Artistic Scoring Class, we calculate last-trick
    scores and follow the rulebook (or do we?)"
  end

  def lower_is_better
    false
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "freestyle_scores"
  end

  def competitor_dq?(_competitor)
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "Flatland"
  end

  def scoring_path(judge)
    judge_scores_path(judge)
  end

  def include_event_name
    true
  end

  def requires_age_groups
    false
  end
end
