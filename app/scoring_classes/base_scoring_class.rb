class BaseScoringClass
  include Rails.application.routes.url_helpers

  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  # describes how to label the results of this competition
  def result_description
    raise StandardError.new("No Result Description Defined")
  end

  def example_result
    nil
  end

  def imports_points?
    false
  end

  def competitor_dq_status_description(_)
    "DQ"
  end

  def imports_times?
    false
  end

  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def results_importable
    !uses_judges
  end

  def uses_judges
    false
  end

  def uses_volunteers
    false
  end

  def results_path
    nil
  end

  def freestyle_summary?
    false
  end

  # Do the competitors compete in a pre-defined order?
  def compete_in_order?
    false
  end

  def build_result_from_imported(_import_result)
    raise NotImplementedError
  end

  def requires_age_groups
    true
  end

  def can_eliminate_judges?
    false
  end
end
