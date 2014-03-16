class RaceCalculator

  def initialize(competition)
    @competition = competition
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  # update the places for all age groups
  def update_all_places
    @competition.time_results.includes(:competitor).reorder("minutes, seconds, thousands").each do |tr|
      age_place_calc = get_place_calculator(tr.competitor.age_group_entry_description)
      gender_place_calc = get_place_calculator(tr.competitor.gender)

      tr.competitor.place = age_place_calc.place_next(tr.full_time_in_thousands, tr.disqualified, tr.competitor.ineligible)
      tr.competitor.overall_place = gender_place_calc.place_next(tr.full_time_in_thousands, tr.disqualified, tr.competitor.ineligible)
    end
  end
end
