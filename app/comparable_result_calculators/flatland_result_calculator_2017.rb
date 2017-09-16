class FlatlandResultCalculator_2017 # rubocop:disable Style/ClassAndModuleCamelCase
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
    nil
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor, with_ineligible: nil) # rubocop:disable Lint/UnusedMethodArgument
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    total_last_trick_points(competitor)
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      scores: [judge: :judge_type]
    )
  end

  # Return the resulting score for this competitor
  # after having eliminated the highest and lowest total score
  # Note: There is only 1 judge-type for flatland
  def total_points(competitor)
    scores = competitor.scores.map(&:total).compact

    scores.reduce(:+) # sum the values
  end

  def total_points_for_judge_type(competitor, _judge_type, with_ineligible: nil) # rubocop:disable Lint/UnusedMethodArgument
    total_points(competitor)
  end

  private

  # the last_trick points are stored in val_5
  def total_last_trick_points(competitor)
    scores = competitor.scores

    last_trick_scores = scores.map {|s| s.val_5.to_i}
    last_trick_scores.reduce(:+) || 0
  end
end
