class DistanceCalculator
  # FOR TWO-ATTEMPT-DISTANCE (like High/Long jump)

  def initialize(competition)
    @competition = competition
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  # update the places for all age groups
  def update_all_places
    # returns distance_attempts in descending (longest-first) order
    @competition.best_distance_attempts.each do |da|
      age_place_calc = get_place_calculator(da.age_group_entry_description)
      gender_place_calc = get_place_calculator("Overall: #{da.gender}") # differentiate between Overall and an age group named "Male"

      da.competitor.place = age_place_calc.place_next(da.result, da.disqualified, da.ineligible)
      da.competitor.overall_place = gender_place_calc.place_next(da.result, da.disqualified, da.ineligible)
    end
  end
end
