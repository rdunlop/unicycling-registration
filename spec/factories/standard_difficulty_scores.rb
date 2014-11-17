# == Schema Information
#
# Table name: standard_difficulty_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  devaluation                     :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#
# Indexes
#
#  standard_diff_judge_routine_comp  (judge_id,standard_skill_routine_entry_id,competitor_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_difficulty_score do
    association :competitor, :factory => :event_competitor
    standard_skill_routine_entry # FactoryGirl
    judge # FactoryGirl
    devaluation 50
  end
end
