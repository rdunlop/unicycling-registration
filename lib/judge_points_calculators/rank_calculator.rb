# Given a set of scores,
# and a given score,
# determine that resulting rank of that score
# including breaking any ties
class RankCalculator
  attr_accessor :lower_is_better

  def initialize(total_points_per_competitor, tie_break_points_per_competitor = nil)
    @total_points_per_competitor = total_points_per_competitor
    @tie_break_points_per_competitor = tie_break_points_per_competitor
    @lower_is_better = true
  end

  # determine the rank of a given score (points)
  #
  # If tie-break points are also given, we may use the tie_break_points_per_competitor to break a tie
  def rank(my_points, my_tie_break_points = nil)
    my_place = 1
    @total_points_per_competitor.each_with_index do |comp_points, index|
      next if comp_points == 0

      if compared_score_is_better(my_points, comp_points)
        my_place = my_place + 1
      elsif comp_points == my_points
        if tie_break_scores? && compared_score_is_better(my_tie_break_points, @tie_break_points_per_competitor[index])
          my_place = my_place + 1
        end
      end
    end
    my_place
  end

  private

  def tie_break_scores?
    @tie_break_points_per_competitor.present?
  end


  def compared_score_is_better(my_score, compared_score)
    if lower_is_better
      compared_score < my_score
    else
      compared_score > my_score
    end
  end
end
