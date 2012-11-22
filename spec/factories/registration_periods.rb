# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date "2012-11-22"
    end_date "2012-11-22"
    competitor_cost 1
    noncompetitor_cost 1
    name "MyString"
  end
end
