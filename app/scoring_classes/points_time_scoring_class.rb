class PointsTimeScoringClass < BaseScoringClass
  def initialize(competition)
    super(competition)
  end

  def scoring_description
    "Externally scored competition results are entered, in which the points and time
    of competitors are entered, and a 'details' column, which is a description of the result
    (for use on the awards/results sheets). Higher points are better, and lower time is better in case of a tie."
  end

  # describes how to label the results of this competition
  def result_description
    "Score"
  end

  def example_result
    "13pts (15m 7s)"
  end

  def render_path
    "trials_results"
  end

  def competitor_dq?(competitor)
    competitor.trials_result.try(:disqualified?)
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.trials_results
  end

  def uses_judges
    false
  end

  def uses_volunteers
    [:data_recording_volunteer]
  end

  def results_path
    competition_trials_results_path(competition)
  end

  def requires_age_groups
    false
  end
end
