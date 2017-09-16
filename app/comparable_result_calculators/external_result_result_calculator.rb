class ExternalResultResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.external_result.try(:active?)
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      competitor.external_result.try(:details)
    end
  end

  def competitor_comparable_result(competitor, with_ineligible: nil) # rubocop:disable Lint/UnusedMethodArgument
    if competitor.has_result?
      competitor.external_result.points
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :external_result
    )
  end
end
