# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    user # FactoryGirl
    completed false
    cancelled false
    transaction_id "MyString"
    completed_date "2012-11-23 03:22:05"
  end
end
