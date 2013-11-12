class TimedEventClass
  def initialize(competition)
    @competition = competition
  end

  # Function which places all of the 
  def place_all
    true
  end

  def result_description
    nil
  end

  def competitor_has_result(competitor)
    false
  end

  def competitor_result(competitor)
    if self.competitor_has_result(competitor)
      nil
    else
      nil
    end
  end

  def all_competitor_results
    nil
  end

  def results_path
  end

  def create_import_result_from_csv(line)
  end

  def create_result_from_import_result(import_result)
  end
end
