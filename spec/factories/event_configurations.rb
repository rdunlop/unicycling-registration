# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_configuration do
    short_name "My conv"
    long_name "Some really nice convention"
    location "Somewhere"
    dates_description "X through Y"
    event_url "http://www.naucc.com"
    start_date "2013-1-1"
    #logo ""
    currency "$"
    contact_email "robinc@dunlopweb.com"
    closed false
    artistic_closed_date "2013-1-10"
    standard_skill_closed_date "2013-3-10"
    tshirt_closed_date "2013-5-10"
    test_mode true
  end
end
