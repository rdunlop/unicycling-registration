# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date Date.new(2012,11,03)
    end_date Date.new(2022,11,27)
    association :competitor_expense_item, factory: :expense_item, cost: 100
    association :noncompetitor_expense_item, factory: :expense_item, cost: 50
    name "Name"
    onsite false
  end
end
