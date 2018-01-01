require 'spec_helper'

describe MassEmail do
  describe "when sending e-mails" do
    let(:addresses) do
      Array.new(50).map do |i|
        "example#{i}@example.com"
      end
    end

    let!(:user) { FactoryGirl.create(:user) }
    let(:email) { FactoryGirl.create(:mass_email, sent_by: user, email_addresses: addresses) }

    it "sends multiple notifications" do
      ActionMailer::Base.deliveries.clear
      expect do
        email.send_emails
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
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
