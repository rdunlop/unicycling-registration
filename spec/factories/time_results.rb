# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_result do
    event_category nil # FactoryGirl can't do this
    registrant # FactoryGirl
    disqualified false
    minutes 0
    seconds 0
    thousands 0
  end
end
