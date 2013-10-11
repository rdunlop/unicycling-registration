# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :refund do
    user # FactoryGirl
    refund_date "2013-10-11 09:35:39"
    note "MyString"
  end
end
