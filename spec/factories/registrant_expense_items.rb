# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_expense_item do
    registrant #FactoryGirl
    expense_item #FactoryGirl
  end
end
