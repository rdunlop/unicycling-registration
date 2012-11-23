# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_detail do
    payment_id 1
    registrant_id 1
    amount "9.99"
  end
end
