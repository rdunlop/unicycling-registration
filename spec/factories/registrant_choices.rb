# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_choice do
    registrant # FactoryGirl
    event_choice # FactoryGirl
    value "0"
  end
end
