class Freestyle_2017_JudgePointsCalculator # rubocop:disable Naming/ClassAndModuleCamelCase
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

  def calculate_score_total(score)
    calculator = case score.judge_type.name
                 when "Technical"
                   ScoreWeightCalculator::Weighted.new([25, 37.5, 37.5])
                 when "Performance"
                   ScoreWeightCalculator::Equal.new
                 when "Dismount"
                   ScoreWeightCalculator::Dismount.new(score.competitor.active_members.size)
                 end
    calculator.total(score.raw_scores)
  end
end
