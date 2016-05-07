# == Schema Information
#
# Table name: standard_skill_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer          not null
#  judge_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_scores_on_competitor_id               (competitor_id)
#  index_standard_skill_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

class StandardSkillScore < ActiveRecord::Base
  include Competeable
  belongs_to :judge
  has_many :standard_skill_score_entries, dependent: :destroy, inverse_of: :standard_skill_score

  validates :judge_id, presence: true, uniqueness: {scope: [:competitor_id]}
  delegate :event, to: :competitor

  accepts_nested_attributes_for :standard_skill_score_entries

  def total_difficulty_devaluation
    standard_skill_score_entries.to_a.sum(&:difficulty_devaluation_score)
  end

  def wave_count
    standard_skill_score_entries.sum(:wave)
  end

  def line_count
    standard_skill_score_entries.sum(:line)
  end

  def cross_count
    standard_skill_score_entries.sum(:cross)
  end

  def circle_count
    standard_skill_score_entries.sum(:circle)
  end

  def total_execution_devaluation
    (wave_count * 0.5) + line_count + (cross_count * 2) + (circle_count * 3)
  end

  def total_devaluation
    total_difficulty_devaluation + total_execution_devaluation
  end
end
