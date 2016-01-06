class StandardSkillResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.standard_skill_scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
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
    # maximum Execution score
    base_points = get_base_points(competitor)

    total_score = competitor.standard_skill_scores.to_a.sum do |skill_score|
      base_points - skill_score.total_execution_devaluation
    end

    total_score / competitor.standard_skill_scores.count
  end

  # Calculate the total number of points for a given competitor
  # Minimum value is 0
  #
  # return a numeric
  def total_points(competitor)
    base_points = get_base_points(competitor)

    total_score = competitor.standard_skill_scores.to_a.sum do |skill_score|
      base_points - skill_score.total_execution_devaluation - skill_score.total_difficulty_devaluation
    end

    # minimum value is 0
    [0, total_score / competitor.standard_skill_scores.count].max
  end

  private

  def get_base_points(competitor)
    competitor.standard_skill_routine.total_skill_points
  end
end
