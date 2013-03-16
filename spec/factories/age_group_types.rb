# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :age_group_type do
    sequence(:name) {|n| "AgeGroup #{n}"}
  end
end
