# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :volunteer_opportunity do
    sequence(:description) { |n| "Artistic Judge #{n}" }
    display_order 1
    inform_emails "test@dunlopweb.com"
  end
end
