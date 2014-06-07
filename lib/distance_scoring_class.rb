class DistanceScoringClass < BaseScoringClass

  def scoring_description
    "Å competitor can attempt repeatedly, scoring higher distances. Eventually the competitor
    will double-fault, and their last successful distance will be their final score.
    The competitor with the highest max distance will win."
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    OrderedResultCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    "Distance"
  end

  def render_path
    "distance_attempts"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.distance_attempts.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      max_distance = competitor.max_successful_distance
      "#{max_distance} cm" unless max_distance == 0
    else
      nil
    end
  end

  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.max_successful_distance
    else
      nil
    end
  end

  def competitor_comparable_result(competitor)
    if self.competitor_has_result?(competitor)
      # larger score is better, so invert this result so that the sorting is correct
      -competitor.max_successful_distance || 0
    else
      0
    end
  end

  def competitor_dq?(competitor)
    return false if competitor.best_distance_attempt.nil?
    competitor.best_distance_attempt.fault
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def uses_judges
    true
  end
end
