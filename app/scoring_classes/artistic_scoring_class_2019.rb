class ArtisticScoringClass_2019 < BaseScoringClass # rubocop:disable Naming/ClassAndModuleCamelCase
  def scoring_description
    "Using the Freestyle scoring rules, multiple Performance, Technical, and Dismount judges
    will score each competitor, and then the resulting points (converted to percentages, and summed) will be used to
    calculate the winner. As per the IUF 2019 Rulebook" # changed
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

  def freestyle_summary?
    true
  end

  def competitor_dq?(_competitor)
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "Artistic Freestyle IUF 2019" # changed
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
