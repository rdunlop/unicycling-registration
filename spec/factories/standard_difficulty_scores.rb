# == Schema Information
#
# Table name: standard_difficulty_scores
#
#  id                              :integer          not null, primary key
#  competitor_id                   :integer
#  standard_skill_routine_entry_id :integer
#  judge_id                        :integer
#  devaluation                     :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_difficulty_score do
    competitor { FactoryGirl.create(:event_competitor) }
    standard_skill_routine_entry # FactoryGirl
    judge # FactoryGirl
    devaluation 50
  end
end
