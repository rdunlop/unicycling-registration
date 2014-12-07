class ArtisticScoreCalculator
  def initialize(competition, unicon_scoring = true)
    @competition = competition # should use this some where in the calculations?
    @unicon_scoring = unicon_scoring # should do 'elimination' for each judge_type
  end

  def update_all_places
    @competition.competitors.each do |competitor|
      new_place  = place(competitor)
      Result.create_new!(competitor, new_place, "Overall")
    end
  end

  def compared_score_is_better(my_score, compared_score, lower_is_better)
    if lower_is_better
      compared_score < my_score
    else
      compared_score > my_score
    end
  end
  # ####################################################################
  #   BY EVENT (all scores, all judges)
  # ####################################################################
  #
  # this should be in "Competitor", but I'm putting here because
  # I don't want to clutter Competitor (which is not always Score-based)
  def new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor, lower_numbers_are_better = true)
    my_place = 1
    total_points_per_competitor.each_with_index do |comp_points, index|
      next if comp_points == 0

      if compared_score_is_better(my_points, comp_points, lower_numbers_are_better)
        my_place = my_place + 1
      elsif comp_points == my_points
        if compared_score_is_better(my_tie_break_points, tie_break_points_per_competitor[index], lower_numbers_are_better)
          my_place = my_place + 1
        end
      end
    end
    my_place
  end

  def place(competitor)
    @place ||= {}
    unless @place[competitor.id].nil?
      return @place[competitor.id]
    end

    competitors = competitor.competition.competitors.active

    my_points = total_points(competitor)
    total_points_per_competitor = competitors.map { |comp| total_points(comp) }

    jt = JudgeType.find_by_name("Technical") # TODO this should be properly identified
    my_tie_break_points = total_points(competitor, jt)
    tie_break_points_per_competitor = competitors.map { |comp| total_points(comp, jt) }

    my_place = new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)
    if my_points == 0 || !competitors.include?(competitor) # inactive competitor
      my_place = 0
    end

    @place[competitor.id] = my_place
  end

  def get_placing_points_for_judge_type(competitor, judge_type)
    Rails.cache.fetch("/comp/#{competitor.id}-#{competitor.updated_at}/judge_type/#{judge_type.try(:id)}") do
      if judge_type.nil?
        scores = competitor.scores
      else
        scores = competitor.scores.select {|s| judge_type == s.judge_type }
      end
      scores.map {|s| s.placing_points }
    end
  end

  def new_total_points(competitor)
    placing_points_for_all_judges = get_placing_points_for_judge_type(competitor, nil)

    total_points = placing_points_for_all_judges.reduce(:+) # sum the remaining values

    min = new_lowest_score(placing_points_for_all_judges)
    max = new_highest_score(placing_points_for_all_judges)

    (total_points - min - max)
  end

  def total_points(competitor, judge_type = nil)
    # only caching the most common query
    if judge_type.nil?
      @total_points ||= {}
      unless @total_points[competitor.id].nil?
        # Enabling this cache breaks flatland judging...don't know why XXX
        # return @total_points[competitor.id]
      end
    end

    if judge_type.nil?
      if @unicon_scoring
        total = 0
        competitor.competition.judge_types.uniq.each do |jt|
          total += total_points_for_judge_type(competitor, jt)
        end
      else
        total = total_points_for_judge_type(competitor, nil)
      end
    else
      total = total_points_for_judge_type(competitor, judge_type)
    end

    if judge_type.nil?
      @total_points[competitor.id] = total
    else
      total
    end
  end

  def eliminate_high_and_low_score(scores)
    max = scores.max
    remaining = scores - [max]
    min = scores.min
    remaining = scores - [min]

    remaining.reduce(:+) # sum the remaining values
  end

  def total_points_for_judge_type(competitor, judge_type)
    scores = get_placing_points_for_judge_type(competitor, judge_type)

    unless scores.count > 2
      return 0
    end

    min = lowest_score(competitor, judge_type)
    max = highest_score(competitor, judge_type)

    total_points = scores.reduce(:+) # sum the remaining values

    (total_points - min - max)
  end

  # 5.10.1 Removing The High And Low
  # After determining placing points as above, discard the highest and lowest placing score
  # for each rider. If Rider A has scores of 1,2,1,3,2, take out one of the ones, and the three.
  # Then Rider A has 1,2,2, for a total of 5. If Rider B has scores of 2,2,2,2,2, he will end
  # up with 2,2,2, a total of 6. The winner is the competitor with the lowest total placing
  # points score after the high and low have been removed.
  #
  # 5.10.2 Ties
  # If more than one competitor has the same placing score after the above process, those
  # riders will be ranked based on their placing scores for Technical. The scoring process
  # must be repeated using only the Technical scores for the tied riders to determine this
  # rank. High and low placing scores are again removed in the process. If competitors'
  # Technical ranking comes out equal, all competitors with the same score are awarded the
  # same place.

  def new_highest_score(placing_points)
    placing_points.max
  end

  def new_lowest_score(placing_points)
    placing_points.min
  end

  def highest_score(competitor, judge_type = nil)
    get_placing_points_for_judge_type(competitor, judge_type).max
  end

  def lowest_score(competitor, judge_type = nil)
    get_placing_points_for_judge_type(competitor, judge_type).min
  end
end
