class StreetScoringClass < BaseScoringClass
  def scoring_description
    "A varation of the artistic scoring, for use in street comp"
  end

  def lower_is_better
    true
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "freestyle_scores"
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "Street"
  end

  def scoring_path(judge)
    judge_street_scores_path(judge)
  end

  def competitor_dq?(competitor)
    false
  end

  def requires_age_groups
    false
  end

  def compete_in_order?
    true
  end
end
