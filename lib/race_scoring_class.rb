class RaceScoringClass < BaseScoringClass

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    RaceCalculator.new(@competition)
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

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
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
end
