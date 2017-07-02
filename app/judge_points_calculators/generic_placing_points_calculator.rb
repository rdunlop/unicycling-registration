# Given a set of scores, where a higher score is better
#
# judged_place - convert that into places
# judged_points - convert the place(s) into points (including splitting placing_points for ties)
class GenericPlacingPointsCalculator
  attr_accessor :points_per_rank
  attr_accessor :lower_is_better

  def initialize(options = {})
    @points_per_rank = options[:points_per_rank] || (1..100).to_a
    @lower_is_better = options[:lower_is_better] || false
  end

  def calculate_score_total(score)
    ScoreWeightCalculator::Equal.new.total(score.raw_scores)
  end

  # Return the numeric place of this score, compared to the results of the other scores by this judge
  # Input: score: the numeric score in question
  # input: all_scores: an array of numeric other results
  #
  # result an integer place
  def judged_place(scores, score)
    if lower_is_better
      better_scores = scores.count { |each_score| each_score < score }
    else
      better_scores = scores.count { |each_score| each_score > score }
    end

    better_scores + 1
  end

  # Return the calculated total points for this score
  # which will probably be related to the other scores by this judge
  #
  # returns a numeric (probably afraction)
  def judged_points(all_scores, score)
    place = judged_place(all_scores, score)
    my_ties = all_scores.count(score) - 1

    points(place, my_ties)
  end

  # this should be a separate class, so that I can make this private
  # perhaps extract out the judged_points function?
  def points(place, ties)
    total_points = 0
    current_place = place
    (ties + 1).times do
      total_points += points_for(current_place)
      current_place += 1
    end
    total_points.to_f / (ties + 1)
  end

  def points_for(rank)
    return 0 if rank > points_per_rank.length
    points_per_rank[rank - 1]
  end
end
