# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_detail do
    payment # FactoryGirl
    registrant # FactoryGirl
    amount "9.99"
  end
end
