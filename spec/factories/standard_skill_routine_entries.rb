# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :standard_skill_routine_entry do
    standard_skill_routine # FactoryGirl
    standard_skill_entry
    position 1
  end
end
