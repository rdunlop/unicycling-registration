class TrialsResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.trials_result.try(:active?)
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      return if competitor.trials_result.status == "DQ"

      competitor.trials_result.details
    end
  end

  def competitor_comparable_result(competitor, with_ineligible: nil) # rubocop:disable Lint/UnusedMethodArgument
    if competitor.has_result?
      # Assuming the time result is less than 11.5 days (1,000,000 seconds)
      (competitor.trials_result.points * 1_000_000) - (competitor.trials_result.minutes * 60) - competitor.trials_result.seconds
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :trials_result
    )
  end
end
