class DistanceResultCalculator
  def scoring_description
    "Å competitor can attempt repeatedly, scoring higher distances. Eventually the competitor
    will double-fault, and their last successful distance will be their final score.
    The competitor with the highest max distance will win."
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      max_distance = competitor.max_successful_distance
      "#{max_distance} cm" unless max_distance == 0
    else
      nil
    end
  end

  def competitor_comparable_result(competitor)
    if competitor.has_result?
      competitor.max_successful_distance
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    competitor.tie_breaker_adjustment_value
  end
end
