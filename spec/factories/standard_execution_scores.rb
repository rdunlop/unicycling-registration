# == Schema Information
#
# Table name: standard_execution_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  wave                            :integer
#  line                            :integer
#  cross                           :integer
#  circle                          :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#
# Indexes
#
#  standard_exec_judge_routine_comp  (judge_id,standard_skill_routine_entry_id,competitor_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_execution_score do
    association :competitor, factory: :event_competitor
    standard_skill_routine_entry # FactoryGirl
    judge # FactoryGirl
    wave 1
    line 1
    cross 1
    circle 1
  end
end
