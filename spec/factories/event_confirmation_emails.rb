# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_confirmation_email do
    subject "Email {{ID}} Subject"
    body "some text to be sent to {{FirstName}}"
    reply_to_address "robin@example.com"
  end
end

# == Schema Information
#
# Table name: event_confirmation_emails
#
#  id               :bigint(8)        not null, primary key
#  sent_by_id       :integer
#  reply_to_address :string
#  subject          :string
#  body             :text
#  sent_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
