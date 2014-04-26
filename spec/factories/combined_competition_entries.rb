# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition_entry do
    combined_competition # FactoryGirl
    abbreviation "MyString"
    tie_breaker false
    points_1 50
    points_2 42
    points_3 34
    points_4 27
    points_5 21
    points_6 15
    points_7 10
    points_8 6
    points_9 3
    points_10 1
  end
end
