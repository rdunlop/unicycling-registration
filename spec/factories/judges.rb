# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :judge do
    event_category { FactoryGirl.create(:event).event_categories.first }
    judge_type # Use FactoryGirl to create
    user       # Use FactoryGirl to create
  end
end
