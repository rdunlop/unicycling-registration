# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    category # FactoryGirl
    sequence(:name) {|n| "Teh event number #{n}" }
    export_name "SomeName"
    position 1
    event_class "Freestyle"

    factory :distance_event do
      event_class "Two Attempt Distance" 
    end

    factory :street_event do
      event_class "Street"
    end

    factory :flatland_event do
      event_class "Flatland"
    end

    factory :timed_event do
      event_class "Distance"
    end
  end
end
