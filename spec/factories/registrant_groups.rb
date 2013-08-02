# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group do
    name "MyString"
    association :contact_person, factory: :registrant
  end
end
