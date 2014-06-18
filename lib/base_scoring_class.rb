class BaseScoringClass
  include Rails.application.routes.url_helpers

  def initialize(competition)
    @competition = competition
  end

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    raise StandardError.new("No Score Calculator Defined")
  end

  # describes how to label the results of this competition
  def result_description
    raise StandardError.new("No Result Description Defined")
  end

  def example_result
    nil
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    raise StandardError.new("No Has Result Defined")
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    raise StandardError.new("No Competitor Result Defined")
  end

  # Function which places all of the competitors in the competition
  def place_all
    nil
  end

  def imports_times
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  # the page where all of the results for this competition are listed
  def results_path
    result_competition_path(I18n.locale, @competition)
  end

  def results_importable
    !uses_judges
  end

  def uses_judges
    false
  end

  # Do the competitors compete in a pre-defined order?
  def compete_in_order
    false
  end

  def build_result_from_imported(import_result)
    raise NotImplementedError
  end

  def build_import_result_from_raw(raw)
    raise NotImplementedError
  end

  def requires_age_groups
    true
  end
end
