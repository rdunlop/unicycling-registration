# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :volunteer_choice do
    volunteer_opportunity # FactoryGirl
    registrant # Factory
  end
end
