class ScoreWeightCalculator::Weighted
  attr_reader :score_weights

  def initializer(score_weights)
    @score_weights = score_weights
    raise unless score_weights.sum(:+) == 100
  end

  def total(score)
    sum = 0
    score.class.score_fields.each_with_index do |sym, index|
      sum += score.send(sym) * score_weights[index]
    end
    sum / 100.0
  end
end
