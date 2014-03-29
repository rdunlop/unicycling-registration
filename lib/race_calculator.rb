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
      age_place_calc = get_place_calculator(tr.age_group_entry_description)
      gender_place_calc = get_place_calculator("Overall: #{tr.gender}") # differentiate between Overall and an age group named "Male"

      tr.competitor.place = age_place_calc.place_next(tr.result, tr.disqualified, tr.ineligible)
      tr.competitor.overall_place = gender_place_calc.place_next(tr.result, tr.disqualified, tr.ineligible)
    end
  end
end
