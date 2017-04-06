class StreetResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
    nil
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

  def eager_load_results_relations(competitors)
    competitors.includes(
      scores: [judge: :judge_type]
    )
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
