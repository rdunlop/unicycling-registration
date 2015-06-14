class RaceResultCalculator
  attr_accessor :lower_is_better

  def initialize(lower_is_better = true)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "Each competitor may have multiple time results. A time result is made up
    of an optional 'start time' and a required 'end time'. The #{lower_is_better ? 'Faster' : 'Slower'} time
    is used to determine the placing of the competitor."
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      TimeResultPresenter.new(competitor.best_time_in_thousands).full_time
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result?
      competitor.best_time_in_thousands
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    nil
  end
end
