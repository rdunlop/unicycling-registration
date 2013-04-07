# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :age_group_entry do
    age_group_type #FactoryGirl
    sequence(:short_description) { |n| "MyString #{n}" }
    long_description "MyString"
    start_age 1
    end_age 100
    gender "Male"
  end
end
