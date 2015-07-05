class ArtisticResultCalculator_2015
  def scoring_description
    "Using the Freestyle scoring rules, multiple Performance and Technical judges
    will score each competitor, and then the resulting points (converted to percentage of points) will be used to
    calculate the winner. As per the IUF 2015 Rulebook"
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

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    jt = JudgeType.find_by(name: "Technical", event_class: competitor.competition.event_class) # TODO this should be properly identified
    total_points(competitor, jt)
  end

  # Calculate the total number of points for a given competitor
  # judge_type: if specified, limit the results to a given judge_type.
  # NOTE: This function takes into account the "removed scores" by chief judge
  #
  # return a numeric
  def total_points(competitor, judge_type = nil)
    if judge_type.nil?
      scores = competitor.scores.joins(:judge).merge(Judge.active)
      # XXX need to gather the results by judge_type, so that I can average them?
    else
      scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: judge_type.id }).merge(Judge.active)
    end

    active_scores = scores.map(&:placing_points).compact

    (active_scores.sum / active_scores.count.to_f).round(2)
  end
end
