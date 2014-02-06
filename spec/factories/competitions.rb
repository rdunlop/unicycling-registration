# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition do
    event # FactoryGirl
    sequence(:name) {|n| "Competition #{n}"}
    locked false
    gender_filter "Both"
    scoring_class "Freestyle"

    factory :distance_competition do
      scoring_class "Two Attempt Distance"
    end

    factory :street_competition do
      scoring_class "Street"
    end

    factory :flatland_competition do
      scoring_class "Flatland"
    end

    factory :timed_competition do
      scoring_class "Distance"
    end
  end
end
