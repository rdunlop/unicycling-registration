class SumScoreCalculator
  attr_accessor :score

  def initialize(score)
    @score = score
  end

  def calculate
    score.class.score_fields.inject(0){ |sum, sym| sum + score.send(sym) }
  end
end
