# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_group do
    group_name "MyString"
    visible true
    position 1
  end
end
