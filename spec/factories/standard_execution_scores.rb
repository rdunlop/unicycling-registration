# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_execution_score do
    competitor { FactoryGirl.create(:event_competitor) }
    standard_skill_routine_entry # FactoryGirl
    judge # FactoryGirl
    wave 1
    line 1
    cross 1
    circle 1
  end
end
