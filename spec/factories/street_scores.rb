# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :street_score do
    competitor { FactoryGirl.create(:event_competitor) }
    judge # use FactoryGirl
    val_1 0.0
  end
end
