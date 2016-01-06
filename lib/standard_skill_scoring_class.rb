class StandardSkillScoringClass < BaseScoringClass
  def scoring_description
    "Using the Standard Skill scoring rules, multiple Writing Judges will score each competitor.
    The resulting scores will be added up, and the highest resulting score will be the winner."
  end

  def lower_is_better
    false
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "standard_skill_scores"
  end

  def competitor_dq?(_competitor)
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    "Standard Skill"
  end

  def scoring_path(judge)
    judge_standard_skill_scores_path(judge)
  end

  def compete_in_order?
    true
  end

  def requires_age_groups
    false
  end

  def can_eliminate_judges?
    false
  end
end
