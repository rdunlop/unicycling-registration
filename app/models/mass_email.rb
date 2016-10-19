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

class MassEmail < ApplicationRecord
  belongs_to :sent_by, class_name: "User"

  validates :sent_by, presence: true

  def send_emails
    first_index = 0
    current_set = email_addresses.slice(first_index, 30)
    until current_set == [] || current_set.nil?
      Notifications.send_mass_email(subject, body, current_set).deliver_later
      first_index += 30
      current_set = email_addresses.slice(first_index, 30)
    end
  end
end
