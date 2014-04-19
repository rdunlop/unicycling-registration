class StreetCompScoreCalculator < ArtisticScoreCalculator

  def initialize(competition)
    @calc = ArtisticScoreCalculator.new(competition) # should use this some where in the calculations?
  end

  # ####################################################################
  #   BY SCORE (JUDGE)
  # ####################################################################
  # determining the place points for this score (by-judge)

  def calc_place(score)
    @calc_place ||= {}
    unless @calc_place[score.id].nil?
      return @calc_place[score.id]
    end
    unless score.valid?
      return 0
    end

    my_place = 1
    score.judge.get_scores.each do |each_score|
      # Lower is better
      if each_score.total < score.total
        my_place = my_place + 1
      end
    end
    @calc_place[score.id] = my_place
  end




  # ####################################################################
  #   BY EVENT (all scores, all judges)
  # ####################################################################
  #
  # this should be in "Competitor", but I'm putting here because
  # I don't want to clutter Competitor (which is not always Score-based)
  def place(competitor)
    @place ||= {}
    unless @place[competitor.id].nil?
      return @place[competitor.id]
    end

    my_points = total_points(competitor)
    total_points_per_competitor     = competitor.competition.competitors.map { |comp| total_points(comp) }

    tie_break_points_per_competitor = competitor.competition.competitors.map { |comp| 0 }

    my_place = new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)

    @place[competitor.id] = my_place
  end

  def total_points_for_judge_type(competitor, judge_type)
    scores = get_placing_points_for_judge_type(competitor, judge_type)

    scores.reduce(:+) # sum the values (no high/low elimination)
  end
end
