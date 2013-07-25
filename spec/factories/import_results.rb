# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_result do
    user # FactoryGirl
    competition # FactoryGirl
    raw_data "MyString"
    bib_number 1
    minutes 1
    seconds 1
    thousands 1
    disqualified false
  end
end
