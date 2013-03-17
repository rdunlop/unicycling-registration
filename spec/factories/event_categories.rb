# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_category do
    event # FactoryGirl
    sequence(:name) {|n| "EventCategory #{n}"}
    position 1
  end
end
