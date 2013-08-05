class ExternallyRankedCalculator

  def initialize(competition)
    @competition = competition
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  # update the places for all age groups
  def update_all_places
    @competition.external_results.includes(:competitor).order("rank").each do |er|
      age_place_calc = get_place_calculator(er.competitor.age_group_entry_description)
      gender_place_calc = get_place_calculator(er.competitor.gender)

      er.competitor.place = age_place_calc.place_next(er.rank, false, er.competitor.ineligible)
      er.competitor.overall_place = gender_place_calc.place_next(er.rank, false, er.competitor.ineligible)
    end
  end
end
