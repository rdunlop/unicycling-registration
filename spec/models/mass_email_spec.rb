require 'spec_helper'

describe MassEmail do
  describe "validations" do
    let(:user) { FactoryBot.create(:user) }

    it "is valid with subject and body" do
      email = MassEmail.new(subject: "Test", body: "Body", sent_by: user)
      expect(email).to be_valid
    end

    it "requires subject" do
      email = MassEmail.new(body: "Body", sent_by: user)
      expect(email).not_to be_valid
      expect(email.errors[:subject]).to be_present
    end

    it "requires body" do
      email = MassEmail.new(subject: "Subject", sent_by: user)
      expect(email).not_to be_valid
      expect(email.errors[:body]).to be_present
    end

    it "requires sent_by" do
      email = MassEmail.new(subject: "Subject", body: "Body")
      expect(email).not_to be_valid
      expect(email.errors[:sent_by]).to be_present
    end
  end

  describe "#include_my_email?" do
    let(:user) { FactoryBot.create(:user) }
    let(:email) { MassEmail.new(sent_by: user) }

    it "is falsey when nil" do
      email.include_my_email = nil
      expect(email).not_to be_include_my_email
    end

    it "is falsey when '0'" do
      email.include_my_email = "0"
      expect(email).not_to be_include_my_email
    end

    it "is truthy when '1'" do
      email.include_my_email = "1"
      expect(email).to be_include_my_email
    end

    it "is truthy when true" do
      email.include_my_email = true
      expect(email).to be_include_my_email
    end
  end

  describe "#reply_to_emails_to_store" do
    let(:user) { FactoryBot.create(:user, email: "sender@example.com") }
    let(:email) { MassEmail.new(sent_by: user) }

    it "returns empty string when nothing is set" do
      email.include_my_email = nil
      email.additional_reply_to_emails = nil
      expect(email.reply_to_emails_to_store(user)).to eq("")
    end

    it "includes user email when checkbox is checked" do
      email.include_my_email = "1"
      email.additional_reply_to_emails = nil
      expect(email.reply_to_emails_to_store(user)).to eq("sender@example.com")
    end

    it "parses and strips additional emails" do
      email.include_my_email = nil
      email.additional_reply_to_emails = "a@example.com, b@example.com"
      expect(email.reply_to_emails_to_store(user)).to eq("a@example.com, b@example.com")
    end

    it "deduplicates user email from additional emails" do
      email.include_my_email = "1"
      email.additional_reply_to_emails = "sender@example.com, a@example.com"
      result = email.reply_to_emails_to_store(user)
      expect(result).to include("sender@example.com")
      expect(result).to include("a@example.com")
      expect(result.split(", ").length).to eq(2)
    end

    it "ignores blank additional emails" do
      email.include_my_email = nil
      email.additional_reply_to_emails = "a@example.com, , b@example.com"
      result = email.reply_to_emails_to_store(user)
      expect(result).to eq("a@example.com, b@example.com")
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
