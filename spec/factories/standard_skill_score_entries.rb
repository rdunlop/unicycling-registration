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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_score_entry do
    association :standard_skill_score
    standard_skill_routine_entry # FactoryGirl
    difficulty_devaluation_percent 0
    wave 0
    line 0
    cross 0
    circle 0
  end
end
