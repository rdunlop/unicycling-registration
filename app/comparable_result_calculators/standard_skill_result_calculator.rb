class StandardSkillResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.standard_skill_scores.any?
  end

  # returns the result to be displayed for this competitor
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
    return 0 if competitor.standard_skill_scores.none?
    # maximum Execution score
    base_points = get_base_points(competitor)

    total_score = competitor.standard_skill_scores.to_a.sum do |skill_score|
      base_points - skill_score.total_execution_devaluation
    end

    total_score / competitor.standard_skill_scores.count
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :standard_skill_scores,
      standard_kill_routine: [standard_skill_routine_entries: :standard_skill_entry]
    )
  end

  # Calculate the total number of points for a given competitor
  # Minimum value is 0
  #
  # return a numeric
  def total_points(competitor)
    base_points = get_base_points(competitor)

    total_score = competitor.standard_skill_scores.to_a.sum do |skill_score|
      [0, base_points - skill_score.total_execution_devaluation - skill_score.total_difficulty_devaluation].max
    end

    # minimum value is 0
    total_score / competitor.standard_skill_scores.count
  end

  private

  def get_base_points(competitor)
    competitor.standard_skill_routine.total_skill_points
  end
end
