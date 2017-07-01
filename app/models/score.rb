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
#  val_5         :decimal(5, 3)
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

class Score < ApplicationRecord
  include Judgeable

  SCORES_RANGE = (1..5).freeze

  def self.score_fields
    SCORES_RANGE.map{|i| "val_#{i}".to_sym }
  end

  score_fields.each do |sym|
    validates sym, presence: true, numericality: {greater_than_or_equal_to: 0}
  end
  before_validation :set_zero_for_non_applicable_scores

  validate :values_within_judge_type_bounds

  delegate :judge_type, to: :judge
  delegate :judge_score_calculator, to: :competition

  def display_score?(score_number)
    judge_type.score_column_enabled?(score_number)
  end

  # Sum of all entered values for this score.
  def total
    return nil if invalid? || competitor.ineligible?

    judge_score_calculator.calculate_score_total(self)
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

  def score_symbol(score_number)
    "val_#{score_number}".to_sym
  end

  def score_value(score_number)
    send(score_symbol(score_number))
  end

  def raw_scores
    @raw_scores = []

    judge_type.score_numbers.each do |score_number|
      @raw_scores << score_value(score_number)
    end

    @raw_scores
  end

  private

  def set_zero_for_non_applicable_scores
    if judge && judge_type
      SCORES_RANGE.each do |score_number|
        unless display_score?(score_number)
          send("val_#{score_number}=", 0)
        end
      end
    end
  end

  def values_within_judge_type_bounds
    if judge && judge.judge_type && all_values_present
      jt = judge.judge_type
      self.class::SCORES_RANGE.each do |score_number|
        validate_judge_score(score_number, jt.max_score_for(score_number))
      end
    end
  end

  def all_values_present
    self.class::SCORES_RANGE.all? { |score_number| score_value(score_number) }
  end

  def validate_judge_score(score_number, max_score)
    if score_value(score_number) > max_score
      value_sym = score_symbol(score_number)
      errors[value_sym] << "#{value_sym} must be <= #{max_score}"
    end
  end
end
