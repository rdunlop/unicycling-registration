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
    age_group_competitors = competitors.select { |c| c.age_group_entry == entry }
    update_age_group_entry_results_with(age_group_competitors)
  end

  def update_age_group_results
    update_age_group_entry_results_with(competitors)
  end

  def update_overall_results
    competitors_in_sorted_order_with_ineligible = CompetitorOrderer.new(competitors, lower_is_better, use_with_ineligible_score: true).sort

    if competition.score_ineligible_competitors?
      placed_competitors = competitors_in_sorted_order_with_ineligible.map do |competitor|
        gender_place_calc = get_place_calculator("Overall: #{competitor.gender}") # differentiate between Overall and an age group named "Male"
        new_place = gender_place_calc.place_next(competitor.comparable_score_with_ineligible, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?)
        { competitor: competitor, new_place: new_place }
      end
      Result.create_new_results!(placed_competitors, "Overall")
    else
      # score the ineligibles..for fake-y
      placed_competitors = competitors_in_sorted_order_with_ineligible.map do |competitor|
        gender_place_calc = get_place_calculator("Overall Ineligible: #{competitor.gender}") # differentiate between Overall and an age group named "Male"
        new_place = gender_place_calc.place_next(competitor.comparable_score_with_ineligible, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
        if competitor.ineligible?
          { competitor: competitor, new_place: new_place }
        end
      end
      Result.create_new_results!(placed_competitors, "Overall")

      # score the eligibles
      competitors_in_sorted_order = CompetitorOrderer.new(competitors, lower_is_better, use_with_ineligible_score: false).sort
      competitors_in_sorted_order = competitors_in_sorted_order.reject(&:ineligible?)
      placed_competitors = competitors_in_sorted_order.map do |competitor|
        gender_place_calc = get_place_calculator("Overall Eligible: #{competitor.gender}") # differentiate between Overall and an age group named "Male"
        new_place = gender_place_calc.place_next(competitor.comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?)
        { competitor: competitor, new_place: new_place }
      end
      Result.create_new_results!(placed_competitors, "Overall")
    end
  end

  private

  def update_age_group_entry_results_with(selected_competitors)
    competitors_in_sorted_order_with_ineligible = CompetitorOrderer.new(selected_competitors, lower_is_better, use_with_ineligible_score: true).sort

    if competition.score_ineligible_competitors?
      placed_competitors_with_subtype = competitors_in_sorted_order_with_ineligible.map do |competitor|
        gender_place_calc = get_place_calculator("AgeGroup: #{competitor.age_group_entry_description}")
        new_place = gender_place_calc.place_next(competitor.comparable_score_with_ineligible, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?)
        { competitor: competitor, new_place: new_place, subtype: competitor.age_group_entry_description }
      end
      placed_competitors_with_subtype.group_by { |placed_competitor| placed_competitor[:subtype] }.each do |subtype, placed_competitors|
        Result.create_new_results!(placed_competitors, "AgeGroup", subtype)
      end
    else
      # score the ineligibles..for fake-y
      placed_competitors_with_subtype = competitors_in_sorted_order_with_ineligible.map do |competitor|
        gender_place_calc = get_place_calculator("AgeGroup Ineligible: #{competitor.age_group_entry_description}")
        new_place = gender_place_calc.place_next(competitor.comparable_score_with_ineligible, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
        if competitor.ineligible?
          { competitor: competitor, new_place: new_place, subtype: competitor.age_group_entry_description }
        end
      end
      placed_competitors_with_subtype.compact.group_by { |placed_competitor| placed_competitor[:subtype] }.each do |subtype, placed_competitors|
        Result.create_new_results!(placed_competitors, "AgeGroup", subtype)
      end

      # score the eligibles
      competitors_in_sorted_order = CompetitorOrderer.new(selected_competitors, lower_is_better, use_with_ineligible_score: false).sort
      competitors_in_sorted_order = competitors_in_sorted_order.reject(&:ineligible?)
      placed_competitors_with_subtype = competitors_in_sorted_order.map do |competitor|
        gender_place_calc = get_place_calculator("AgeGroup Eligible: #{competitor.age_group_entry_description}")
        new_place = gender_place_calc.place_next(competitor.comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?)
        { competitor: competitor, new_place: new_place, subtype: competitor.age_group_entry_description }
      end

      placed_competitors_with_subtype.group_by { |placed_competitor| placed_competitor[:subtype] }.each do |subtype, placed_competitors|
        Result.create_new_results!(placed_competitors, "AgeGroup", subtype)
      end
    end
  end

  def all_competitors_in_sorted_order
    @all_competitors_in_sorted_order ||= competitors_in_sorted_order(competitors)
  end

  def competitors_in_sorted_order(selected_competitors)
    @competitors_in_sorted_order ||= CompetitorOrderer.new(selected_competitors, lower_is_better).sort
  end
end
