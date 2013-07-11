# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :judge_type do
    sequence(:name) { |n| "Presentation #{n}" }
    event_class "Freestyle"

    val_1_description "Mistakes"
    val_2_description "Intepretation"
    val_3_description "Mastery"
    val_4_description "Magic"
    val_1_max 10
    val_2_max 10
    val_3_max 10
    val_4_max 10
    boundary_calculation_enabled false
  end
end
