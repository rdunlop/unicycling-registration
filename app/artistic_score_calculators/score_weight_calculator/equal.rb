class ScoreWeightCalculator::Equal
  def total(score)
    score.class.score_fields.inject(0){ |sum, sym| sum + score.send(sym) }
  end
end
