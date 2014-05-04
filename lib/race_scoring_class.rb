class RaceScoringClass < BaseScoringClass

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    OrderedResultCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    "Time"
  end

  def render_path
    "time_results"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.time_results.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.time_results.first.try(:full_time)
    else
      nil
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.time_results.first.try(:full_time_in_thousands)
    else
      nil
    end
  end

  def competitor_dq?(competitor)
    if self.competitor_has_result?(competitor)
      competitor.time_results.first.disqualified
    else
      false
    end
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end

  def ordered_results
    @competition.time_results.includes(:competitor).reorder("minutes, seconds, thousands")
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.time_results
  end

  # the page where all of the results for this competition are listed
  def results_path
    scores_competition_path(I18n.locale, @competition)
  end

  def results_importable
    true
  end

  def uses_judges
    false
  end

  def include_event_name
    false
  end

  def uses_lane_assignments
    true
  end

  def build_result_from_imported(import_result)
    TimeResult.new(
      minutes: import_result.minutes,
      seconds: import_result.seconds,
      thousands: import_result.thousands,
      disqualified: import_result.disqualified,
      is_start_time: import_result.is_start_time)
  end

  def build_import_result_from_raw(raw)
    ImportResult.new(
      bib_number: raw[0],
      minutes: raw[1],
      seconds: raw[2],
      thousands: raw[3],
      disqualified: (raw[4] == "DQ"))
  end
end
