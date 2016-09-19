# == Schema Information
#
# Table name: standard_skill_score_entries
#
#  id                              :integer          not null, primary key
#  standard_skill_score_id         :integer          not null
#  standard_skill_routine_entry_id :integer          not null
#  difficulty_devaluation_percent  :integer          default(0), not null
#  wave                            :integer          default(0), not null
#  line                            :integer          default(0), not null
#  cross                           :integer          default(0), not null
#  circle                          :integer          default(0), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  standard_skill_entries_unique  (standard_skill_score_id,standard_skill_routine_entry_id) UNIQUE
#

class StandardSkillScoreEntry < ApplicationRecord
  belongs_to :standard_skill_routine_entry
  belongs_to :standard_skill_score, inverse_of: :standard_skill_score_entries, touch: true

  validates :standard_skill_score, presence: true
  validates :standard_skill_routine_entry_id, presence: true

  validates :difficulty_devaluation_percent, presence: true, inclusion: { in: [0, 50, 100] }
  validates :wave, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :line, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :cross, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :circle, presence: true, numericality: {greater_than_or_equal_to: 0}

  def difficulty_devaluation_score
    return 0 unless valid?
    standard_skill_routine_entry.points * (difficulty_devaluation_percent / 100.0)
  end
end
