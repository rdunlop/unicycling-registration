class OrderedResultCalculator
  attr_reader :competition

  def initialize(competition)
    @competition = competition
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  # update the places for all age groups
  def update_all_places

    competition.ordered_results.each do |result|
      age_place_calc = get_place_calculator(result.age_group_entry_description)
      gender_place_calc = get_place_calculator("Overall: #{result.gender}") # differentiate between Overall and an age group named "Male"

      result.competitor.place = age_place_calc.place_next(result.result, result.disqualified, result.ineligible)
      result.competitor.overall_place = gender_place_calc.place_next(result.result, result.disqualified, result.ineligible)
    end
  end
end
