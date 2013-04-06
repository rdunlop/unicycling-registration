# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :additional_registrant_access do
    user # FactoryGirl
    registrant # FactoryGirl
    declined false
    accepted_readonly false
  end
end
