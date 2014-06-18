class OrderedResultCalculator
  attr_reader :competition, :lower_is_better

  def initialize(competition, lower_is_better = true)
    @competition = competition
    @lower_is_better = lower_is_better
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  # update the places for all age groups
  def update_all_places

    competitors_in_sorted_order.each do |competitor|

      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      gender_place_calc = get_place_calculator("Overall: #{competitor.gender}") # differentiate between Overall and an age group named "Male"

      competitor.place = age_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
      competitor.overall_place = gender_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
    end
  end

  private

  def competitors_in_sorted_order
    if lower_is_better
      competition.competitors.sort{ |a, b| a.comparable_score <=> b.comparable_score}
    else
      competition.competitors.sort{ |a, b| b.comparable_score <=> a.comparable_score}
    end
  end
end
