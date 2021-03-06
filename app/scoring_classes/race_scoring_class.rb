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
    competitor.has_result? && (competitor.time_results.all?(&:disqualified?) || competitor.best_time_in_thousands.zero?)
  end

  def competitor_dq_status_description(competitor)
    return nil unless competitor_dq?(competitor)

    if competitor.time_results.any?
      descriptions = competitor.time_results.map(&:status_description).compact.uniq
      ["DQ", *descriptions].compact.join(" ")
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
    %i[data_recording_volunteer race_official track_data_importer]
  end

  def results_path
    competition_time_results_path(competition)
  end

  def build_result_from_imported(import_result)
    status = import_result.status.nil? ? "active" : import_result.status
    TimeResult.new(
      minutes: import_result.minutes,
      seconds: import_result.seconds,
      thousands: import_result.thousands,
      number_of_penalties: import_result.number_of_penalties,
      status: status,
      comments: import_result.comments,
      comments_by: import_result.comments_by,
      number_of_laps: import_result.number_of_laps,
      is_start_time: import_result.is_start_time,
      entered_at: import_result.created_at,
      entered_by: import_result.user
    )
  end

  def imports_times?
    true
  end
end
