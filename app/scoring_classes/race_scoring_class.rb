class RaceScoringClass < BaseScoringClass
  attr_accessor :lower_is_better

  def initialize(competition, lower_is_better = true)
    super(competition)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "Each competitor may have multiple time results. A time result is made up
    of an optional 'start time' and a required 'end time'. The #{lower_is_better ? 'Faster' : 'Slower'} time
    is used to determine the placing of the competitor."
  end

  # def lower_is_better
  # attr_accessor (see above)

  # describes how to label the results of this competition
  def result_description
    "Time"
  end

  def example_result
    "1:30:23"
  end

  def render_path
    "time_results"
  end

  # Determine whether a competitor is disqualified
  # NOTE: this should be improved to indicate DNS/DNF/DQ, if at all possible
  def competitor_dq?(competitor)
    competitor.has_result? && (competitor.time_results.all?(&:disqualified?) || competitor.best_time_in_thousands == 0)
  end

  def competitor_dq_status_description(competitor)
    return nil unless competitor_dq?(competitor)

    if competitor.time_results.any?
      time_result = competitor.time_results.order(:id).last
      ["DQ", time_result.status_description].compact.join(" ")
    else
      "DQ"
    end
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.time_results
  end

  def uses_judges
    false
  end

  def uses_volunteers
    [:data_recording_volunteer, :race_official, :track_data_importer]
  end

  def results_path
    competition_time_results_path(competition)
  end

  def imports_times?
    true
  end
end
