# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_choice do
    registrant_id 1
    event_choice_id 1
    value "MyString"
  end
end
