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
#
# Indexes
#
#  index_judge_types_on_name_and_event_class  (name,event_class) UNIQUE
#

class JudgeType < ActiveRecord::Base
  has_many :judges, dependent: :destroy
  has_many :competitions, through: :judges
  has_many :scores, through: :judges

  validates :name, presence: true, uniqueness: { scope: :event_class }
  validates :event_class, inclusion: { in: Competition.scoring_classes }

  validates :val_1_description, presence: true
  validates :val_2_description, presence: true
  validates :val_3_description, presence: true
  validates :val_4_description, presence: true

  validates :val_1_max, presence: true
  validates :val_2_max, presence: true
  validates :val_3_max, presence: true
  validates :val_4_max, presence: true
  validates :boundary_calculation_enabled, inclusion: { in: [false] }  # boundary calculations are disabled

  after_initialize :init

  def init
    self.val_1_max ||= 10
    self.val_2_max ||= 10
    self.val_3_max ||= 10
    self.val_4_max ||= 10
  end

  def num_columns
    res = 0
    res += 1 if val_1_max > 0
    res += 1 if val_2_max > 0
    res += 1 if val_3_max > 0
    res += 1 if val_4_max > 0
    res
  end

  def to_s
    name
  end

  def score_calculator
    case name
    #when "Presentation"

    when "Dismount"
      DismountScoreCalculator
    else
      SumScoreCalculator
    end
  end
end
