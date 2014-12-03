class OverallChampionScoringClass < BaseScoringClass
  def scoring_description
    "Uses the chosen Overall Champion Calculation to determine the input competitors.
    Calculates the Overall Champion, and stores their final scores and places"
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    @score_calculator ||= CombinedCompetitionResult.new(@competition.combined_competition, @competition)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def example_result
    nil
  end

  def render_path
    "overall_champion"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    true # always indicate that we have a result, so that all competitors are created.
  end

  # returns the overall points calculated for this competitor
  def competitor_result(competitor)
    nil
  end

  def competitor_comparable_result(competitor)
    score_calculator.competitor_score(competitor)
  end

  def imports_times
    false
  end

  def competitor_dq?(competitor)
    false
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end

  def requires_age_groups
    false
  end
end
