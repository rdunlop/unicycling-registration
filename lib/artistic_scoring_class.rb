class ArtisticScoringClass < BaseScoringClass

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    # XXX Should make this a configuration somewhere
    unicon_scoring = false
    ArtisticScoreCalculator.new(@competition, unicon_scoring)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      nil# not applicable in Freestyle
    else
      nil
    end
  end

  # Function which places all of the competitors in the competition
  def place_all
    nil
  end


  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  # the page where all of the results for this competition are listed
  def results_path
    freestyle_scores_competition_path(I18n.locale, @competition)
  end


  def results_importable
    false
  end

  def uses_judges
    true
  end

  def include_event_name
    true
  end
end
