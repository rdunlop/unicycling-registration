module JudgeScoreable
  extend ActiveSupport::Concern

  included do
    self.score_fields.each do |sym|
      validates sym, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    end
    validate :values_within_judge_type_bounds

    delegate :judge_type, to: :judge
  end

  module ClassMethods
    def score_fields
      []
    end
  end

  def validate_judge_score(value_sym, max_score)
    if self.send(value_sym) > max_score
      errors[value_sym] << "#{value_sym.to_s} must be <= #{max_score}"
    end
  end

  def all_values_present
    self.class.score_fields.all? { |sym| self.send(sym) }
  end

  def values_within_judge_type_bounds
    if judge && judge.judge_type && all_values_present
      jt = judge.judge_type
      self.class.score_fields.each do |sym|
        validate_judge_score(sym, jt.send("#{sym}_max"))
      end
    end
  end

  def total
    if self.invalid?
      0
    else
      self.class.score_fields.inject(0){ |sum, sym| sum + self.send(sym) }
    end
  end

  def new_calc_place(score, scores)
    my_place = 1
    scores.each do |each_score|
      if each_score > score
        my_place = my_place + 1
      end
    end
    my_place
  end

  def new_ties(score, scores)
    ties = 0
    scores.each do |each_score|
      if each_score == score
        ties = ties + 1
      end
    end
    ties
  end

  def ties # always has '1' tie...with itself
    # XXX refactor this redundant code:
    scores_for_judge = judge.score_totals
    new_ties(total, scores_for_judge)
  end

  def judged_place
    scores_for_judge = judge.score_totals
    new_calc_place(total, scores_for_judge)
  end

  def new_calc_placing_points(my_place, num_ties)
    total_placing_points = 0
    num_ties.times do
      total_placing_points = total_placing_points + my_place
      my_place = my_place + 1
    end
    (total_placing_points * 1.0) / num_ties
  end

  def placing_points
    new_calc_placing_points(judged_place, ties)
  end
end
