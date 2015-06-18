class StreetScoringClass < BaseScoringClass
  attr_accessor :lower_is_better

  def initialize(competition, lower_is_better = true)
    super(competition)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "A varation of the artistic scoring, for use in street comp"
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
