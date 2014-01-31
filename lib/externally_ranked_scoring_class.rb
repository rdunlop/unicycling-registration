class ExternallyRankedScoringClass
  include Rails.application.routes.url_helpers

  def initialize(competition)
    @competition = competition
  end


  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    ExternallyRankedCalculator.new(@competition)
  end

  # describes how to label the results of this competition
  def result_description
    "Score"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.external_results.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      competitor.external_results.first.try(:details)
    else
      nil
    end
  end

  # Function which places all of the competitors in the competition
  def place_all
    score_calculator.update_all_places
  end


  # Used when trying to destroy all results for a competition
  def all_competitor_results
    @competition.external_results
  end

  # the page where all of the results for this competition are listed
  def results_path
    competition_external_results_path(@competition)
  end

  ########### Below this line, the entries are not (YET) used

  # for award_label
  def create_import_result_from_csv(line)
  end

  # for award_label
  def create_result_from_import_result(import_result)
  end
end
