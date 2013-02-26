# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    category # FactoryGirl
    description "Some Description"
    position 1
  end
end
