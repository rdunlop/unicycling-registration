# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :combined_competition do
    sequence(:name) { |n| "MyString #{n}" }
  end
end
