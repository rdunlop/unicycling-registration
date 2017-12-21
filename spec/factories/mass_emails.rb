FactoryGirl.define do
  factory :mass_email do
    association :sent_by, factory: :user
    subject "Hello"
    body "How are you?"
    email_addresses ["one@example.com"]
    email_addresses_description ["All Available"]
  end
end

# == Schema Information
#
# Table name: mass_emails
#
#  id                          :integer          not null, primary key
#  sent_by_id                  :integer          not null
#  sent_at                     :datetime
#  subject                     :string
#  body                        :text
#  email_addresses             :text             is an Array
#  email_addresses_description :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_mass_emails_on_email_addresses  (email_addresses)
#
