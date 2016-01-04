class RaceResultCalculator
  attr_accessor :lower_is_better

  def initialize(lower_is_better = true)
    @lower_is_better = lower_is_better
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.finish_time_results.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result? && !competitor.disqualified?
      TimeResultPresenter.new(competitor.best_time_in_thousands).full_time
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result? && !competitor.disqualified?
      competitor.best_time_in_thousands
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end
end
