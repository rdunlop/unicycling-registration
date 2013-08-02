# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group_member do
    registrant_group # FactoryGirl
    registrant # FactoryGirl
  end
end
