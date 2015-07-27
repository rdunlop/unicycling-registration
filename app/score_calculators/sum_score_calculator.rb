class SumScoreCalculator
  attr_accessor :score

  def initialize(score, _number_of_people)
    @score = score
  end

  def calculate
    score.class.score_fields.inject(0){ |sum, sym| sum + score.send(sym) }
  end
end
