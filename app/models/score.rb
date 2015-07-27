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
#  created_at    :datetime
#  updated_at    :datetime
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

  score_fields.each do |sym|
    validates sym, presence: true, numericality: {greater_than_or_equal_to: 0}
  end
  before_validation :set_zero_for_non_applicable_scores

  validate :values_within_judge_type_bounds

  delegate :judge_type, to: :judge
  delegate :judge_score_calculator, to: :competition

  def display_score?(score_number)
    judge_type.send("val_#{score_number}_max") > 0
  end

  # Sum of all entered values for this score.
  def total
    return nil if invalid? || competitor.ineligible?

    judge.calculate_score(self, competitor.members.size)
  end

  # Return the numeric place of this score, compared to the results of the other scores by this judge
  def judged_place
    return nil if invalid? || competitor.ineligible?

    judge_score_calculator.judged_place(judge.score_totals, total)
  end

  # Return this score, after having converted it into placing points
  # which will require comparing it against the scores this judge gave other competitors
  def placing_points
    return nil if invalid? || competitor.ineligible?

    judge_score_calculator.judged_points(judge.score_totals, total)
  end

  private

  def set_zero_for_non_applicable_scores
    if judge && judge_type
      (1..4).each do |score_number|
        unless display_score?(score_number)
          send("val_#{score_number}=", 0)
        end
      end
    end
  end

  def values_within_judge_type_bounds
    if judge && judge.judge_type && all_values_present
      jt = judge.judge_type
      self.class.score_fields.each do |sym|
        validate_judge_score(sym, jt.send("#{sym}_max"))
      end
    end
  end

  def all_values_present
    self.class.score_fields.all? { |sym| send(sym) }
  end

  def validate_judge_score(value_sym, max_score)
    if send(value_sym) > max_score
      errors[value_sym] << "#{value_sym} must be <= #{max_score}"
    end
  end
end
