class StreetResultCalculator
  def scoring_description
    "A varation of the artistic scoring, for use in street comp"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
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

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  # must be exposed in order to allow displaying of per-judge-type points
  def total_points(competitor, judge_type = nil)
    if judge_type.nil?
      scores = competitor.scores
    else
      scores = competitor.scores.select{ |score| score.judge_type == judge_type }
    end
    scores.map(&:placing_points).compact.reduce(:+) || 0
  end
end
