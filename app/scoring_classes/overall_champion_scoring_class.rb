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
      # must create competitors WITH age groups immediately, for the calculation to work correctly
      @competition.create_competitor_from_registrants([Registrant.find_by(bib_number: bib_number)], nil, wait_for_age_group: true)
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

  def competitor_dq?(_competitor)
    false
  end

  def requires_age_groups
    false
  end
end
