# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date "2012-11-23"
    end_date "2012-11-27"
    competitor_cost 10
    noncompetitor_cost 5
    name "MyString"
  end
end
