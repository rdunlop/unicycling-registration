class PointsScoringClass < BaseScoringClass
  attr_accessor :lower_is_better

  def initialize(competition, lower_is_better = true)
    super(competition)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "Externally scored competition results are entered, in which the points
    of competitors is entered, and a 'details' column, which is a description of the result
    (for use on the awards/results sheets). #{lower_is_better ? 'Lower' : 'Higher'} points are better"
  end

  # def lower_is_better
  # attr_accessor (see above)

  # describes how to label the results of this competition
  def result_description
    "Score"
  end

  def example_result
    "13pts"
  end

  def render_path
    "external_results"
  end

  def competitor_dq?(competitor)
    competitor.external_result.try(:disqualified?)
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.external_results
  end

  def uses_judges
    false
  end

  def uses_volunteers
    [:data_recording_volunteer]
  end

  def results_path
    competition_external_results_path(competition)
  end

  def requires_age_groups
    false
  end

  def imports_points?
    true
  end
end
