# == Schema Information
#
# Table name: standard_skill_score_entries
#
#  id                              :integer          not null, primary key
#  standard_skill_score_id         :integer          not null
#  standard_skill_routine_entry_id :integer          not null
#  devaluation                     :integer          not null
#  wave                            :integer          not null
#  line                            :integer          not null
#  cross                           :integer          not null
#  circle                          :integer          not null
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
    devaluation 50
    wave 1
    line 1
    cross 1
    circle 1
  end
end
