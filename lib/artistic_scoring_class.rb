class ArtisticScoringClass < BaseScoringClass
  def scoring_description
    "Using the Freestyle scoring rules, multiple Presentation and Technical judges
    will score each competitor, and then the resulting placing points will be used to
    calculate the winner"
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

  def competitor_dq?(competitor)
    false
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
end
