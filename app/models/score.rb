# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

class Score < ActiveRecord::Base
  include Judgeable

  def self.score_fields
    [:val_1, :val_2, :val_3, :val_4]
  end

  self.score_fields.each do |sym|
    validates sym, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  end
  before_validation :set_zero_for_non_applicable_scores

  validate :values_within_judge_type_bounds

  delegate :judge_type, to: :judge

  def set_zero_for_non_applicable_scores
    if judge && judge_type
      (1..4).each do |score_number|
        if judge_type.send("val_#{score_number}_max") == 0
          self.send("val_#{score_number}=", 0)
        end
      end
    end
  end

  def display_score(score_number)
    judge.judge_type.send("val_#{score_number}_max") > 0
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

  def lower_is_better
    case judge_type.event_class
    when "Freestyle"
      false
    when "Street"
      false
    when "Flatland"
      false
    end
  end

  def new_calc_place(score, scores)
    my_place = 1
    scores.each do |each_score|
      if (lower_is_better && each_score < score) || (!lower_is_better && score < each_score)
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
    ties - 1 # eliminate tie-with-self from scores
  end

  def ties # always has '1' tie...with itself
    # XXX refactor this redundant code:
    scores_for_judge = judge.score_totals
    new_ties(total, scores_for_judge)
  end

  def judged_place
    return 0 if invalid?
    scores_for_judge = judge.score_totals
    new_calc_place(total, scores_for_judge)
  end

  def placing_points
    judge_type.convert_place_to_points(judged_place, ties)
  end
end
