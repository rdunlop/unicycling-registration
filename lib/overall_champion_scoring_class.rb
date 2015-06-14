class OverallChampionScoringClass < BaseScoringClass
  def scoring_description
    "Uses the chosen Overall Champion Calculation to determine the input competitors.
    Calculates the Overall Champion, and stores their final scores and places"
  end

  # Remove all competitors, and re-add them to the competition
  def rebuild_competitors(bib_numbers)
    clear_competitors
    build_competitors(bib_numbers)
  end

  def clear_competitors
    @competition.competitors.destroy_all
  end

  def build_competitors(bib_numbers)
    bib_numbers.each do |bib_number|
      @competition.create_competitor_from_registrants([Registrant.find_by(bib_number: bib_number)], nil)
    end
    @competition.reload
  end

  def lower_is_better
    false
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

  def imports_times
    false
  end

  def competitor_dq?(competitor)
    false
  end

  def requires_age_groups
    false
  end
end
