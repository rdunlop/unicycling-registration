class StreetScoringClass
  include Rails.application.routes.url_helpers

  def initialize(competition)
    @competition = competition
  end


  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    StreetScoreCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    false
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
    nil
  end

  def results_importable
    false
  end

  def uses_judges
    true
  end
  ########### Below this line, the entries are not (YET) used

  # for award_label
  def create_import_result_from_csv(line)
  end

  # for award_label
  def create_result_from_import_result(import_result)
  end
end
