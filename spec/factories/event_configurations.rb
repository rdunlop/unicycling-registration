# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_configuration do
    short_name "MyString"
    long_name "MyString"
    location "MyString"
    dates_description "MyString"
    event_url "MyString"
    start_date "2012-11-10"
    logo ""
    currency "MyString"
    contact_email "MyString"
    closed false
    artistic_closed_date "2012-11-10"
    standard_skill_closed_date "2012-11-10"
    tshirt_closed_date "2012-11-10"
  end
end
