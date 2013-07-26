# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lane_assignment do
    competition # FactoryGirl
    registrant_id 1
    heat 1
    lane 1
  end
end
