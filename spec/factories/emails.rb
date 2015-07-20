# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    subject "Email Subject"
    body "some text to be sent"
    confirmed_accounts false
    unpaid_reg_accounts false
  end
end
