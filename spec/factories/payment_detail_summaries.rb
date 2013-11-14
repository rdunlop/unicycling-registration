# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_detail_summary do
    skip_create

    expense_item # FactoryGirl
    payment # FactoryGirl
    count 1
    amount 10.0
  end
end
