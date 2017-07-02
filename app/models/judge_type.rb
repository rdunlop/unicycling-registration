# == Schema Information
#
# Table name: judge_types
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  val_1_description            :string(255)
#  val_2_description            :string(255)
#  val_3_description            :string(255)
#  val_4_description            :string(255)
#  val_1_max                    :integer
#  val_2_max                    :integer
#  val_3_max                    :integer
#  val_4_max                    :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  event_class                  :string(255)
#  boundary_calculation_enabled :boolean          default(FALSE), not null
#  val_5_description            :string
#  val_5_max                    :integer
#
# Indexes
#
#  index_judge_types_on_name_and_event_class  (name,event_class) UNIQUE
#

class JudgeType < ApplicationRecord
  has_many :judges, dependent: :destroy
  has_many :competitions, through: :judges
  has_many :scores, through: :judges

  validates :name, presence: true, uniqueness: { scope: :event_class }
  validates :event_class, inclusion: { in: Competition.scoring_classes }

  Score.score_fields.each do |sym|
    validates "#{sym}_description", presence: true # val_1_description
    validates "#{sym}_max", presence: true # val_1_max
  end

  validates :boundary_calculation_enabled, inclusion: { in: [false] } # boundary calculations are disabled

  def num_columns
    score_numbers.count
  end

  def score_numbers
    numbers = []
    Score::SCORES_RANGE.each do |score_number|
      # numbers << 1 if val_1_max.positive?
      numbers << score_number if score_column_enabled?(score_number)
    end

    numbers
  end

  def score_attributes
    score_numbers.map{|score_number| "val_#{score_number}".to_sym }
  end

  def description_for(score_number)
    send("val_#{score_number}_description")
  end

  def max_score_for(score_number)
    send("val_#{score_number}_max")
  end

  def score_column_enabled?(score_number)
    max_score_for(score_number).positive?
  end

  def to_s
    name
  end
end
