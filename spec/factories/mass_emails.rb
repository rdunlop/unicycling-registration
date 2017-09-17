FactoryGirl.define do
  factory :mass_email do
    association :sent_by, factory: :user
    subject "Hello"
    body "How are you?"
    email_addresses ["one@example.com"]
    email_addresses_description ["All Available"]
  end
end
