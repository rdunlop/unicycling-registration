# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    sequence(:name) {|n| "Name of Event ##{n}" }
    category # FactoryGirl
    description "Some Description"
    position 1
  end
end
