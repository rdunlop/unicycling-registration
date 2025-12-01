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
    Result.create_new_results!(compute_overall_results, "Overall")
  end

  private

  def update_age_group_entry_results_with(selected_competitors)
    compute_age_group_results(selected_competitors)
      .compact
      .group_by { |placed_competitor| placed_competitor[:subtype] }
      .each { |subtype, placed_competitors| Result.create_new_results!(placed_competitors, "AgeGroup", subtype) }
  end

  def all_competitors_in_sorted_order
    @all_competitors_in_sorted_order ||= competitors_in_sorted_order(competitors)
  end

  def competitors_in_sorted_order(selected_competitors)
    @competitors_in_sorted_order ||= CompetitorOrderer.new(selected_competitors, lower_is_better).sort
  end

  def compute_overall_results
    competitors_in_sorted_order_with_ineligible = CompetitorOrderer.new(competitors, lower_is_better, use_with_ineligible_score: true).sort
    if competition.score_ineligible_competitors?
      compute_places_of_competitors_including_ineligible(competitors_in_sorted_order_with_ineligible, ->(competitor) { "Overall: #{competitor.gender}" })
    else
      placed_ineligible_competitors = compute_places_of_ineligible_competitors(competitors_in_sorted_order_with_ineligible, ->(competitor) { "Overall Ineligible: #{competitor.gender}" })
      placed_eligible_competitors = compute_places_of_eligible_competitors(competitors, ->(competitor) { "Overall Eligible: #{competitor.gender}" })

      placed_ineligible_competitors.concat(placed_eligible_competitors)
    end
  end

  def compute_age_group_results(selected_competitors)
    competitors_in_sorted_order_with_ineligible = CompetitorOrderer.new(selected_competitors, lower_is_better, use_with_ineligible_score: true).sort
    if competition.score_ineligible_competitors?
      compute_places_of_competitors_including_ineligible(competitors_in_sorted_order_with_ineligible, ->(competitor) { "AgeGroup: #{competitor.age_group_entry_description}" })
    else
      placed_ineligible_competitors = compute_places_of_ineligible_competitors(competitors_in_sorted_order_with_ineligible, ->(competitor) { "AgeGroup Ineligible: #{competitor.age_group_entry_description}" })
      placed_eligible_competitors = compute_places_of_eligible_competitors(selected_competitors, ->(competitor) { "AgeGroup Eligible: #{competitor.age_group_entry_description}" })

      placed_ineligible_competitors.concat(placed_eligible_competitors)
    end
  end

  def compute_places_of_competitors_including_ineligible(competitors_in_sorted_order_with_ineligible, group_name_provider)
    competitors_in_sorted_order_with_ineligible.map do |competitor|
      compute_place_of_competitor(competitor, group_name_provider.call(competitor), true)
    end
  end

  def compute_places_of_ineligible_competitors(competitors_in_sorted_order_with_ineligible, group_name_provider)
    competitors_in_sorted_order_with_ineligible.map do |competitor|
      compute_place_of_competitor(competitor, group_name_provider.call(competitor), true, only_ineligible: true)
    end
  end

  def compute_places_of_eligible_competitors(competitors, group_name_provider)
    competitors_in_sorted_order = CompetitorOrderer.new(competitors, lower_is_better, use_with_ineligible_score: false).sort
    competitors_in_sorted_order = competitors_in_sorted_order.reject(&:ineligible?)
    competitors_in_sorted_order.map do |competitor|
      compute_place_of_competitor(competitor, group_name_provider.call(competitor), false)
    end
  end

  def compute_place_of_competitor(competitor, age_group_desc, score_with_ineligible, only_ineligible: false)
    gender_place_calc = get_place_calculator(age_group_desc) # differentiate between Overall and an age group named "Male"

    comparable_score = if score_with_ineligible
                         competitor.comparable_score_with_ineligible
                       else
                         competitor.comparable_score
                       end

    new_place = gender_place_calc.place_next(comparable_score, tie_break_points: competitor.comparable_tie_break_score, dq: competitor.disqualified?, ineligible: competitor.ineligible?)
    if !only_ineligible || competitor.ineligible?
      { competitor: competitor, new_place: new_place, subtype: competitor.age_group_entry_description }
    end
  end
end
