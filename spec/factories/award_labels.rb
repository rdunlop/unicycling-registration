# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :award_label do
    bib_number 1
    competitor_name "Bob Smith"
    competition_name "MyString"
    category "All"
    details "MyString"
    place 1
    user #Factory Girl
    registrant # FactoryGirl
  end
end
