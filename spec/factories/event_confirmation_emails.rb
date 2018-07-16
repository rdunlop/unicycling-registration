# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_confirmation_email do
    subject "Email {{ID}} Subject"
    body "some text to be sent to {{FirstName}}"
    reply_to_address "robin@example.com"
  end
end
