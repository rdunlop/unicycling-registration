require 'spec_helper'

describe MassEmail do
  describe "when sending e-mails" do
    let(:addresses) do
      Array.new(50) do |i|
        "example#{i}@example.com"
      end
    end

    let!(:user) { FactoryBot.create(:user) }
    let(:email) { FactoryBot.create(:mass_email, sent_by: user, email_addresses: addresses) }

    it "sends multiple notifications" do
      ActionMailer::Base.deliveries.clear
      expect do
        email.send_emails
      end.to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it "sends to the originator" do
      ActionMailer::Base.deliveries.clear
      email.send_emails
      expect(ActionMailer::Base.deliveries.first.bcc).to include(user.email)
    end
  end

  describe "#reply_to_addresses" do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { FactoryBot.create(:mass_email, sent_by: user) }

    it "returns contact email when additional emails are blank" do
      email.additional_reply_to_emails = nil
      expect(email.reply_to_addresses).to eq([EventConfiguration.singleton.contact_email])
    end

    it "includes parsed additional addresses" do
      email.additional_reply_to_emails = "extra1@example.com, extra2@example.com"
      result = email.reply_to_addresses
      expect(result).to include(EventConfiguration.singleton.contact_email)
      expect(result).to include("extra1@example.com")
      expect(result).to include("extra2@example.com")
    end

    it "deduplicates addresses" do
      contact_email = EventConfiguration.singleton.contact_email
      email.additional_reply_to_emails = "#{contact_email}, extra@example.com"
      result = email.reply_to_addresses
      expect(result.count(contact_email)).to eq(1)
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
#  additional_reply_to_emails  :string
#
# Indexes
#
#  index_mass_emails_on_email_addresses  (email_addresses) USING gin
#
