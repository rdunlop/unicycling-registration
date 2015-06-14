class StreetResultCalculator
  def scoring_description
    "A varation of the artistic scoring, for use in street comp"
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    end
  end

  def competitor_comparable_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    nil
  end

  private

  def total_points(competitor)
    competitor.scores.map(&:placing_points).reduce(:+) || 0
  end
end
