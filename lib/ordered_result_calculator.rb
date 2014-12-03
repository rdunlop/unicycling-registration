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
    if @competition.has_age_group_entry_results?
      update_age_group_results
    end
    update_overall_results
  end

  def update_age_group_entry_results(entry)
    competitors = competition.competitors.select{ |c| c.age_group_entry == entry }
    competitors_in_sorted_order(competitors).each do |competitor|
      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      new_place = age_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
      Result.create_new!(competitor, new_place, "AgeGroup", competitor.age_group_entry_description)
    end
  end

  def update_age_group_results
    all_competitors_in_sorted_order.each do |competitor|
      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      new_place = age_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
      Result.create_new!(competitor, new_place, "AgeGroup", competitor.age_group_entry_description)
    end
  end

  def update_overall_results
    all_competitors_in_sorted_order.each do |competitor|
      gender_place_calc = get_place_calculator("Overall: #{competitor.gender}") # differentiate between Overall and an age group named "Male"
      new_place = gender_place_calc.place_next(competitor.comparable_score, competitor.disqualified, competitor.ineligible)
      Result.create_new!(competitor, new_place, "Overall")
    end
  end

  private

  def all_competitors_in_sorted_order
    @all_competitors_in_sorted_order ||= competitors_in_sorted_order(competition.competitors.includes(:age_group_results, :overall_results, :time_results))
  end

  def competitors_in_sorted_order(competitors)
    @competitors_in_sorted_order ||= if lower_is_better
                                       competitors.sort{ |a, b| a.comparable_score <=> b.comparable_score}
                                     else
                                       competitors.sort{ |a, b| b.comparable_score <=> a.comparable_score}
    end
  end
end
