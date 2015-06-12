class StreetCompScoreCalculator < ArtisticScoreCalculator
  def initialize(competition)
    super(competition)
  end

  # ####################################################################
  #   BY SCORE (JUDGE)
  # ####################################################################
  # determining the place points for this score (by-judge)

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
    total_points_per_competitor = competitor.competition.competitors.map { |comp| total_points(comp) }

    my_place = RankCalculator.new(total_points_per_competitor).rank(my_points)

    @place[competitor.id] = my_place
  end

  def total_points_for_judge_type(competitor, judge_type)
    scores = get_placing_points_for_judge_type(competitor, judge_type)

    scores.reduce(:+) || 0 # sum the values (no high/low elimination)
  end

  # don't eliminate any scores
  def eliminate_high_and_low_score(scores)
    scores
  end
end
