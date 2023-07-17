class ScoreWeightCalculator::Weighted
  attr_reader :score_weights, :score_ranges

  # score_ranges define the max value for each passed in raw_score
  def initialize(score_weights, score_ranges: [])
    @score_weights = score_weights
    @score_ranges = score_ranges
    raise unless score_weights.sum == 100
  end

  def total(raw_scores)
    sum = 0
    raw_scores.each_with_index do |score, index|
      next if score_weights[index].nil?

      if score_ranges.any?
        sum += score * score_weights[index] / score_range[index]
      else
        sum += score * score_weights[index]
      end
    end
    (sum / 100.0).round(4)
  end
end
