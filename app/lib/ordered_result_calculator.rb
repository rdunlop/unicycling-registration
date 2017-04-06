class OrderedResultCalculator
  attr_reader :competition, :competitors, :lower_is_better

  def initialize(competition, lower_is_better = true)
    @competition = competition

    # TODO: Push this up into the caller, so that we pass in "competitors", and then "include" more'
    calculator = competition.scoring_calculator
    @competitors = calculator.eager_load_results_relations(@competition.competitors)

    @competitors = @competitors.includes(
      # Always need these relations loaded
      :age_group_result,
      :overall_result,
      members: [registrant: [:competition_wheel_sizes]]
    )
    # eager-load other relations, depending on the calculator's needs
    @lower_is_better = lower_is_better
  end

  def get_place_calculator(age_group_desc)
    @place_calculators ||= {}
    @place_calculators[age_group_desc] ||= PlaceCalculator.new
  end

  def update_age_group_entry_results(entry)
    age_group_competitors = competitors.select{ |c| c.age_group_entry == entry }
    competitors_in_sorted_order(age_group_competitors).each do |competitor|
      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      new_place = age_place_calc.place_next(competitor.comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
      Result.create_new!(competitor, new_place, "AgeGroup", competitor.age_group_entry_description)
    end
  end

  def update_age_group_results
    all_competitors_in_sorted_order.each do |competitor|
      age_place_calc = get_place_calculator(competitor.age_group_entry_description)
      new_place = age_place_calc.place_next(competitor.comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
      Result.create_new!(competitor, new_place, "AgeGroup", competitor.age_group_entry_description)
    end
  end

  def update_overall_results
    all_competitors_in_sorted_order.each do |competitor|
      gender_place_calc = get_place_calculator("Overall: #{competitor.gender}") # differentiate between Overall and an age group named "Male"
      new_place = gender_place_calc.place_next(competitor.comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
      Result.create_new!(competitor, new_place, "Overall")
    end
  end

  private

  def all_competitors_in_sorted_order
    @all_competitors_in_sorted_order ||= competitors_in_sorted_order(competitors)
  end

  def competitors_in_sorted_order(selected_competitors)
    @competitors_in_sorted_order ||= CompetitorOrderer.new(selected_competitors, lower_is_better).sort
  end
end
