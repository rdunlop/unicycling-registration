class ExternalResultResultCalculator
  attr_accessor :lower_is_better

  def initialize(lower_is_better = true)
    @lower_is_better = lower_is_better
  end

  def scoring_description
    "Externally scored competition results are entered, in which the points
    of competitors is entered, and a 'details' column, which is a description of the result
    (for use on the awards/results sheets). #{lower_is_better ? 'Lower' : 'Higher'} points are better"
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      competitor.external_results.first.try(:details)
    end
  end

  def competitor_comparable_result(competitor)
    if competitor.has_result?
      competitor.external_results.first.points
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end
end
