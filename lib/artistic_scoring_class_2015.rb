class ArtisticScoringClass_2015 < BaseScoringClass
  def scoring_description
    "Using the Freestyle scoring rules, multiple Performance and Technical judges
    will score each competitor, and then the resulting points (converted to percentage of points) will be used to
    calculate the winner. As per the IUF 2015 Rulebook"
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

  def competitor_dq?(_competitor)
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "Artistic Freestyle IUF 2015"
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
