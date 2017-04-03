class ShortestTimeWithTierCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.finish_time_results.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result? && !competitor.disqualified?
      TimeResultPresenter.from_thousands(competitor.best_time_in_thousands).full_time + tier_description(competitor)
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result? && !competitor.disqualified?
      tier_time(competitor.tier_number) + competitor.best_time_in_thousands
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :start_time_results,
      :finish_time_results
    )
  end

  private

  # convert tier 1 to 0, tier 2 to 11_000_000, tier 3 to 22_000_000
  # so that tier 1 comes in first, and tier 2 comes next
  def tier_time(tier)
    raise "Tier must be >= 1" if tier < 1
    raise "Unable to process tier >= 10" if tier >= 10
    (tier - 1) * 11_000_000
  end

  def tier_description(competitor)
    if competitor.tier_description.present?
      "(#{competitor.tier_description})"
    else
      ""
    end
  end
end
