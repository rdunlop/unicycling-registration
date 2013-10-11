# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :refund_detail do
    refund # FactoryGirl
    payment_detail # FactoryGirl
  end
end
