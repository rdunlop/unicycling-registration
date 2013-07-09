# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :distance_attempt do
    competitor { FactoryGirl.create(:event_competitor) }
    judge      # use FactoryGirl to create
    distance 220
    fault false
  end
end
