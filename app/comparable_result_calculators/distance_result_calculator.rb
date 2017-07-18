class DistanceResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.distance_attempts.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      max_distance = competitor.max_successful_distance
      return if max_distance.nil? || max_distance.zero?
      "#{max_distance} cm"
    end
  end

  # Public: a comparable result, for use when determining the relative ranking of a competitor
  #
  # Returns an integer. Returns 0 if the competitor has no result, or was disqualified/dnf/etc
  def competitor_comparable_result(competitor, with_ineligible: nil)
    if competitor.has_result?
      competitor.max_successful_distance || 0
    else
      0
    end
  end

  # Higher is better
  # those who have tie_break_adjustments are higher than those who don't
  def competitor_tie_break_comparable_result(competitor)
    if competitor.tie_break_adjustment
      1 - (competitor.tie_break_adjustment.tie_break_place * 0.1)
    else
      0
    end
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :distance_attempts,
      :tie_break_adjustment
    )
  end
end
