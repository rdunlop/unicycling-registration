class Freestyle_2015_JudgePointsCalculator
  # Return the numeric place of this score, compared to the results of the other scores by this judge
  def judged_place(all_scores, score)
    better_scores = all_scores.count { |each_score| each_score > score }
    better_scores + 1
  end

  # Return the calculated total points for this score
  # which will probably be related to the other scores by this judge
  #
  # returns a numeric (probably afraction)
  def judged_points(all_scores, score)
    ((score.to_f / all_scores.sum) * 100).round(2)
  end
end
