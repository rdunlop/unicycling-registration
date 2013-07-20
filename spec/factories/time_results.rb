# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_result do
    competitor { FactoryGirl.create(:event_competitor) }
    judge # FactoryGirl
    disqualified false
    minutes 0
    seconds 0
    thousands 0
  end
end
