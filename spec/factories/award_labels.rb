# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :award_label do
    bib_number 1
    first_name "MyString"
    last_name "MyString"
    partner_first_name "MyString"
    partner_last_name "MyString"
    competition_name "MyString"
    team_name "MyString"
    age_group "MyString"
    gender "MyString"
    details "MyString"
    place 1
    user #Factory Girl
    registrant # FactoryGirl
  end
end
