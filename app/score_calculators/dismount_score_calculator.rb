class DismountScoreCalculator
  attr_accessor :major_dismounts
  attr_accessor :minor_dismounts
  attr_accessor :number_of_people

  def initialize(major_dismounts, minor_dismounts, number_of_people = 1)
    @major_dismounts = major_dismounts
    @minor_dismounts = minor_dismounts
    @number_of_people = number_of_people
  end

  def calculate
    return 0 unless major_dismounts && minor_dismounts

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
end
