class ScoreWeightCalculator::Weighted
  attr_reader :score_weights

  def initialize(score_weights)
    @score_weights = score_weights
    raise unless score_weights.sum == 100
  end

  def total(raw_scores)
    sum = 0
    raw_scores.each_with_index do |score, index|
      next if score_weights[index].nil?
      sum += score * score_weights[index]
    end
    sum / 100.0
  end
end
