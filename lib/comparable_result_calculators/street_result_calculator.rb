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

  # must be exposed in order to allow displaying of per-judge-type points
  def total_points(competitor, judge_type = nil)
    if judge_type.nil?
      scores = competitor.scores
    else
      scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: judge_type.id })
    end
    scores.map(&:placing_points).reduce(:+) || 0
  end

  private
end
