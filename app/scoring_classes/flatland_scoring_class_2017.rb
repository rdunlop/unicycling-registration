class FlatlandScoringClass_2017 < BaseScoringClass # rubocop:disable Naming/ClassAndModuleCamelCase
  def scoring_description
    "A variation of the Artistic Scoring Class, we calculate last-trick
    scores and follow the rulebook, As per the IUF 2017 Rulebook"
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

  def compete_in_order?
    true
  end

  def uses_judges
    "Flatland IUF 2017"
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
