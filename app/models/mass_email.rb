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
#  additional_reply_to_emails  :string
#
# Indexes
#
#  index_mass_emails_on_email_addresses  (email_addresses) USING gin
#

class MassEmail < ApplicationRecord
  belongs_to :sent_by, class_name: "User"

  validates :sent_by, presence: true

  def send_emails
    if Rails.configuration.individual_email_sending
      # send emails individually
      addresses.each_slice(10).with_index do |addresses, index|
        # wait a few second for set of emails to prevent hitting SES Rate limit
        addresses.each do |address|
          opt_out_code = MailOptOut.create_if_not_present(address).opt_out_code
          Notifications.send_mass_email(subject, body, [address], opt_out_code, reply_to_addresses).deliver_later(wait: index.seconds * 3)
        end
      end
    else
      # Send emails in groups of 40
      addresses.each_slice(40).with_index do |addresses, index|
        # wait a few second for each email to prevent hitting SES Rate limit
        Notifications.send_mass_email(subject, body, addresses, nil, reply_to_addresses).deliver_later(wait: index.seconds * 3)
      end
    end
  end

  def reply_to_addresses
    ([EventConfiguration.singleton.contact_email] + parsed_additional_reply_to_emails).uniq
  end

  private

  def addresses
    ([sent_by.email] + email_addresses).uniq
  end

  def parsed_additional_reply_to_emails
    additional_reply_to_emails.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
