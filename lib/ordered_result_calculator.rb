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

    competition.competitors.sort{ |a, b| a.comparable_score <=> b.comparable_score}.each do |competitor|

      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      gender_place_calc = get_place_calculator("Overall: #{competitor.gender}") # differentiate between Overall and an age group named "Male"

      competitor.place = age_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
      competitor.overall_place = gender_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
    end
  end
end
