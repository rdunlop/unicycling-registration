# Calculates "Result" entries for all competitors
# in the overall competition
#
class OverallChampionResultCalculator
  attr_accessor :combined_competition, :results_competition
  delegate :percentage_based_calculations?, to: :combined_competition

  def initialize(combined_competition, results_competition = nil)
    @combined_competition = combined_competition
    @results_competition = results_competition
    @scores ||= {}
    @registrant_bib_numbers ||= {}
  end

  def lower_is_better
    false
  end

  def scoring_description
    "Uses the chosen Overall Champion Calculation to determine the input competitors.
    Calculates the Overall Champion, and stores their final scores and places"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(_competitor)
    true # always indicate that we have a result, so that all competitors are created.
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      score = competitor_display_score(competitor)
      "#{score.round(3)} pts"
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result?
      competitor_score(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  # What are the bib numbers of all competitors
  # who have results in the overall competition?
  def competitor_bib_numbers
    registrant_bib_numbers("Male") + registrant_bib_numbers("Female")
  end

  def competitor_score(competitor)
    calc_res = results(competitor.gender).find{ |res| res[:bib_number] == competitor.lowest_member_bib_number }
    calc_res.try(:[], :total_points) || 0
  end

  def competitor_display_score(competitor)
    calc_res = results(competitor.gender).find{ |res| res[:bib_number] == competitor.lowest_member_bib_number }
    calc_res.try(:[], :display_points) || 0
  end

  # bib_number of registrant
  # [place, points] for each type
  #
  # Example:
  # [
  #   {
  #     :bib_number => 10,
  #     :total_points => 187.9,
  #     :display_points => 188,
  #     :results => {
  #       "M" => { :entry_place => 1, :entry_points => 50 },
  #       "TT" => { :entry_place => 1, :entry_points => 33 }
  #     }
  #   },
  #   {
  #     :bib_number => 13,
  #     :total_points => 155,
  #     :display_points => 155,
  #     :results => {
  #       "M" => { :entry_place => 1, :entry_points => 50 },
  #       "TT" => { :entry_place => 1, :entry_points => 33 }
  #     }
  #   }
  # }
  def results(gender)
    if gender == "Male"
      @male_results ||= gather_results("Male")
    else
      @female_results ||= gather_results("Female")
    end
  end

  def calc_points(entry, competitor)
    if percentage_based_calculations?
      calc_perc_points(
        best_time: entry.best_time_in_thousands(competitor.gender),
        time: competitor.best_time_in_thousands,
        base_points: entry.base_points,
        bonus_percentage: entry.bonus_for_place(get_place(competitor)))
    else
      place = get_place(competitor)
      if place > 0 && place <= 10
        entry.send("points_#{get_place(competitor)}")
      else
        0
      end
    end
  end

  def calc_perc_points(best_time:, time:, base_points:, bonus_percentage:)
    return 0 if time == 0
    points = (best_time * 1.0 / time) * base_points
    points + (points * bonus_percentage / 100.0)
  end

  def get_place(competitor)
    return nil if competitor.nil?
    if combined_competition.use_age_group_places?
      competitor.place
    else
      competitor.overall_place
    end
  end

  # creates the initial hash of results for a registrant
  # {
  #   bib_number: the id of the registrant
  #   results: a hash of each competition result
  #   total_points: the comparable_result (including tie-break adjustments)
  #   display_points: the total points
  # }
  def create_registrant_entry(bib_number, gender)
    competitor_results = {}
    combined_competition.combined_competition_entries.each do |entry|
      matching_comp = matching_competitor(bib_number, gender, entry.competition)
      if matching_comp
        points = calc_points(entry, matching_comp)
        competitor_results[entry.abbreviation] = {
          entry_place: get_place(matching_comp),
          entry_points: points
        }
      end
    end
    total_points = 0
    competitor_results.keys.map { |race| total_points += competitor_results[race][:entry_points] }

    {
      bib_number: bib_number,
      results: competitor_results,
      total_points: total_points,
      display_points: total_points,
    }
  end

  def store_score(points, bib_number)
    @scores[points] ||= []
    @scores[points] << bib_number
  end

  def sorted_scores
    @scores.keys.sort.reverse
  end

  def gather_results(gender)
    results = {}
    @scores = {}

    # Create an entry for every competitor
    # store the number of placing points for each competitor
    registrant_bib_numbers(gender).each do |bib_number|
      results[bib_number] = create_registrant_entry(bib_number, gender)
      next if results[bib_number][:total_points] == 0
      store_score(results[bib_number][:total_points], bib_number)
    end

    # for each tie, adjust the placing points by num firsts
    # for each tie, adjust the placing points by tie breaker competition
    # return the resulting score, per competitor

    # break ties
    break_ties_by_firsts = true
    if break_ties_by_firsts
      new_scores = break_ties_by_num_firsts(gender, @scores)
      @scores = new_scores
    end

    if tie_breaker_competition
      new_results = []
      sorted_scores.each do |score|
        tie_break_scores = tie_breaking_scores(gender, score, @scores[score])
        tie_break_scores.each do |calculated_score, bib_number|
          results[bib_number][:total_points] = calculated_score
          new_results << results[bib_number]
        end
      end
      new_results
    else
      new_results = []
      sorted_scores.each do |score|
        @scores[score].each do |bib_number|
          new_results << results[bib_number]
        end
      end
      new_results
    end
  end

  # inputs: gender, and a hash:
  # {
  #   10 => [1,2,3], # bib numbers 1,2 and 3 have score 10
  #   11 => [5], # bib number 5 has score 11
  # }
  # output: a hash:
  # {
  #   10 => [3], # bib number 3 has a score of 10
  #   9.9 => [1,2], # bib numbers 1 and 2 have a score of 9.9
  #   11 => [5], # bib number 5 has a score of 11
  # }
  def break_ties_by_num_firsts(gender, initial_scores)
    new_scores = {}

    initial_scores.keys.each do |single_score|
      if initial_scores[single_score].length > 1
        tie_breakers_for_bib_numbers = {}
        initial_scores[single_score].each do |bib_number|
          tie_breakers_for_bib_numbers[bib_number] = num_firsts(gender, bib_number)
        end
        tie_broken_scores = adjust_ties_by_firsts(single_score, initial_scores[single_score], tie_breakers_for_bib_numbers)
        tie_broken_scores.keys.each do |tie_score|
          new_scores[tie_score] = tie_broken_scores[tie_score]
        end
      else
        new_scores[single_score] = initial_scores[single_score]
      end
    end

    new_scores
  end

  # Input:
  # score, competitors-with-score, and firsts-for-competitors.
  # e.g.
  # score: 10
  # competitors-with-score: [3,2]
  # firsts-for-competitors:
  # {
  #   3 => 1,
  #   2 => 0,
  # }
  #
  # Output:
  # {
  #   10 => [3]
  #   9.9 => [2]
  # }
  def adjust_ties_by_firsts(score, bib_numbers, competitor_firsts_counts)
    firsts_counts = competitor_firsts_counts.values
    adjustment = 0
    result = {}

    firsts_counts.uniq.sort.reverse_each do |num_firsts|
      competitors_with_this_number_of_firsts = competitor_firsts_counts.select{ |el| competitor_firsts_counts[el] == num_firsts }.keys
      current_score = score - adjustment
      competitors_with_this_number_of_firsts
      result[current_score] = competitors_with_this_number_of_firsts
      adjustment += 0.1
    end
    result
  end

  def adjust_ties_by_tie_breaker(scores)
  end

  def num_firsts(gender, bib_number)
    registrants(gender)[bib_number].count{ |comp| get_place(comp) == 1}
  end

  def tie_breaker_competition
    @tie_breaker_competition ||= combined_competition.combined_competition_entries.find_by(tie_breaker: true).try(:competition)
  end

  def place_of_tie_breaker(gender, bib_number)
    @place_of_tie_breaker ||= {}
    # if someone didn't place in  the tie breaker, give them a high place so that they are sorted out properly
    @place_of_tie_breaker[bib_number] ||= get_place(registrants(gender)[bib_number].find{ |comp| comp.competition == tie_breaker_competition }) || 999
  end

  # inputs:
  # gender: "Male"
  # score: 10
  # bib_numbers: [1,2,3]
  #
  # returns
  # [
  #   [score, bib_number],
  #   [score, bib_number],
  #   [score, bib_number]
  # ]
  #
  # example outputs:
  # [
  #   [9.99, 1],
  #   [9.98, 2],
  #   [10, 3]
  # ]
  def tie_breaking_scores(gender, score, bib_numbers)
    if bib_numbers.length > 1
      results = []
      calc_score = score
      places_in_tie_breaker = bib_numbers.map{ |bib_number| place_of_tie_breaker(gender, bib_number) }
      places_in_tie_breaker.uniq.sort.each do |place|
        # each time through this loop is a different (increasing) place in the tie breaker
        bib_numbers.each do |bib_number|
          if place == place_of_tie_breaker(gender, bib_number)
            results << [calc_score, bib_number]
          end
        end
        calc_score -= 0.01
      end
      results
    else
      [[score, bib_numbers[0]]]
    end
  end

  def store_registrants(gender)
    competitors = combined_competition.combined_competition_entries.map{ |entry| entry.competitors(gender) }.flatten

    registrant_bib_numbers = {}

    competitors.each do |comp|
      registrant_bib_numbers[comp.lowest_member_bib_number] ||= []
      registrant_bib_numbers[comp.lowest_member_bib_number] << comp
    end

    registrant_bib_numbers
  end

  def matching_competitor(bib_number, gender, competition)
    @registrant_bib_numbers[gender][bib_number].find { |competitor| competitor.competition == competition }
  end

  def registrants(gender)
    @registrant_bib_numbers[gender] ||= store_registrants(gender)
  end

  def registrant_bib_numbers(gender)
    registrants(gender).keys
  end
end
