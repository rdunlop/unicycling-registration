class DismountScoreCalculator
  attr_accessor :score
  attr_accessor :number_of_people

  def initialize(score, number_of_people = 1)
    @score = score
    @number_of_people = number_of_people
  end

  def calculate
    if effective_people == 1
      score = single_person_score
    else
      score = group_score
    end
    [score, 0].max
  end

  private

  def single_person_score
    10 + (major_dismounts * -1) + (minor_dismounts * -0.5)
  end

  def group_score
    mistake_score = (1 * major_dismounts) + (0.5 * minor_dismounts)
    10 - (mistake_score / number_of_people)
  end

  def effective_people
    if number_of_people <= 2
      1
    else
      number_of_people
    end
  end

  def major_dismounts
    score.val_1
  end

  def minor_dismounts
    score.val_2
  end

end
