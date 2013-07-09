# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_difficulty_score do
    competitor { FactoryGirl.create(:event_competitor) }
    standard_skill_routine_entry # FactoryGirl
    judge # FactoryGirl
    devaluation 50
  end
end
