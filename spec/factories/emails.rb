# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :email do
    subject { "Email Subject" }

    body { "some text to be sent" }
  end
end
