class CombinedCompetitionResult
  attr_accessor :combined_competition, :gender

  def initialize(combined_competition, gender)
    @combined_competition = combined_competition
    @gender = gender
  end

  # bib_number of registrant
  # [place, points] for each type
  #
  # Example:
  # [
  #   {
  #     :place => 1,
  #     :bib_number => 10,
  #     :total_points => 188,
  #     :results => {
  #       10 => { :entry_place => 1, :entry_points => 50 },
  #       11 => { :entry_place => 1, :entry_points => 33 }
  #     }
  #   },
  #   { :place => 2,
  #     :bib_number => 13,
  #     :total_points => 155,
  #     :results => {
  #       10 => { :entry_place => 1, :entry_points => 50 },
  #       11 => { :entry_place => 1, :entry_points => 33 }
  #     }
  #   }
  # }
  def results
    #registrants = combined_competition.combined_competition_entries.map{ |entry| entry.competitors(gender) }.flatten.map{ |comp| comp.registrants.first }.uniq
    @results ||= gather_results
  end

  def create_registrant_entry(bib_number)
    competitor_results = {}
    competitor_points = 0
    combined_competition.combined_competition_entries.each do |entry|
      matching_comp = entry.competitors(gender).select{ |comp| comp.registrants.first.bib_number == bib_number}.first
      if matching_comp
        points = entry.send("points_#{matching_comp.overall_place}")
        competitor_results[entry.abbreviation] = {
          :entry_place => matching_comp.overall_place,
          :entry_points => points
        }
        competitor_points += points
      end
    end
    {
      :bib_number => bib_number,
      :results => competitor_results,
      :total_points => competitor_points
    }
  end

  def gather_results
    results = {}
    registrant_bib_numbers(gender).each do |bib_number|
      results[bib_number] = create_registrant_entry(bib_number)
      store_score(results[bib_number][:total_points], bib_number)
    end

    place_calculator = PlaceCalculator.new
    new_results = []
    sorted_scores.each do |score|
      tie_break_scores = tie_breaking_scores(score, @scores[score])
      tie_break_scores.each do |calculated_score, bib_number|
        reg = Registrant.find_by(:bib_number => bib_number)
        place = place_calculator.place_next(calculated_score, false, reg.ineligible)
        results[bib_number][:place] = place
        new_results << results[bib_number]
      end
    end
    new_results
  end


  def num_firsts(bib_number)
    @registrant_bib_numbers[gender][bib_number].count{ |comp| comp.overall_place == 1}
  end

  def place_of_tie_breaker(bib_number)
    @registrant_bib_numbers[gender][bib_number].select{ |comp| comp.competition.combined_competition_entries.first.tie_breaker }.first.try(:overall_place)
  end

  # returns
  # [
  #   [score, bib_number],
  #   [score, bib_number],
  #   [score, bib_number]
  # ]
  def tie_breaking_scores(score, bib_numbers)
    if bib_numbers.length > 1
      results = []
      firsts_counts = []
      bib_numbers.each do |bib_number|
        firsts_counts << num_firsts(bib_number)
      end
      calc_score = score
      firsts_counts.uniq.sort.reverse.each do |most_firsts|
        bib_numbers_with_this_number_of_firsts = bib_numbers.select{ |bib_number| num_firsts(bib_number) == most_firsts}

        places_in_tie_breaker = bib_numbers_with_this_number_of_firsts.map{ |bib_number| place_of_tie_breaker(bib_number) }
        places_in_tie_breaker.uniq.sort.each do |place|

          bib_numbers_with_this_number_of_firsts.each do |bib_number|
            if place  == place_of_tie_breaker(bib_number)
              results << [calc_score, bib_number]
            end
          end
          calc_score -= 0.1
        end
      end
      results
    else
      [[score, bib_numbers[0]]]
    end
  end

  def store_score(points, bib_number)
    @scores ||= {}
    @scores[points] ||= []
    @scores[points] << bib_number
  end

  def sorted_scores
    @scores.keys.sort.reverse
  end

  def store_registrants(gender)
    competitors = combined_competition.combined_competition_entries.map{ |entry| entry.competitors(gender) }.flatten

    registrant_bib_numbers = {}

    competitors.each do |comp|
      registrant_bib_numbers[comp.registrants.first.bib_number] ||= []
      registrant_bib_numbers[comp.registrants.first.bib_number] << comp
    end

    registrant_bib_numbers
  end

  def registrants(gender)
    @registrant_bib_numbers ||= {}
    @registrant_bib_numbers[gender] ||= store_registrants(gender)
  end

  def registrant_bib_numbers(gender)
    registrants(gender).keys
  end

end
