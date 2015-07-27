class PresentationWithDismountScoreCalculator
  attr_accessor :score
  attr_accessor :dismount_score

  def initialize(score, dismount_score)
    @score = score
    @dismount_score = dismount_score
  end

  def calculate
    dismount_score + score.val_2 + score.val_3 + score.val_4
  end
end
