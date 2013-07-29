# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_result do
    competitor { FactoryGirl.create(:event_competitor) }
    details "MyString"
    rank 1
  end
end
