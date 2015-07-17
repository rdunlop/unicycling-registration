class DistanceResultCalculator
  def scoring_description
    "Å competitor can attempt repeatedly, scoring higher distances. Eventually the competitor
    will double-fault, and their last successful distance will be their final score.
    The competitor with the highest max distance will win."
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.distance_attempts.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      max_distance = competitor.max_successful_distance
      "#{max_distance} cm" unless max_distance == 0
    end
  end

  # Public: a comparable result, for use when determining the relative ranking of a competitor
  #
  # Returns an integer. Returns 0 if the competitor has no result, or was disqualified/dnf/etc
  def competitor_comparable_result(competitor)
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
end
