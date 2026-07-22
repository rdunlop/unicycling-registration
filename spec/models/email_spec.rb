require 'spec_helper'

describe Email do
  before do
    @email = FactoryBot.build(:email)
  end

  it "is initially valid" do
    expect(@email.valid?).to eq(true)
  end

  it "must have a subject" do
    @email.subject = nil
    expect(@email.valid?).to eq(false)
  end

  describe "#include_my_email?" do
    it "is falsey when nil" do
      @email.include_my_email = nil
      expect(@email).not_to be_include_my_email
    end

    it "is falsey when '0'" do
      @email.include_my_email = "0"
      expect(@email).not_to be_include_my_email
    end

    it "is truthy when '1'" do
      @email.include_my_email = "1"
      expect(@email).to be_include_my_email
    end

    it "is truthy when true" do
      @email.include_my_email = true
      expect(@email).to be_include_my_email
    end
  end

  describe "#reply_to_emails_to_store" do
    let(:user) { FactoryBot.create(:user, email: "sender@example.com") }

    it "returns empty string when nothing is set" do
      @email.include_my_email = nil
      @email.additional_reply_to_emails = nil
      expect(@email.reply_to_emails_to_store(user)).to eq("")
    end

    it "includes user email when checkbox is checked" do
      @email.include_my_email = "1"
      @email.additional_reply_to_emails = nil
      expect(@email.reply_to_emails_to_store(user)).to eq("sender@example.com")
    end

    it "parses and strips additional emails" do
      @email.include_my_email = nil
      @email.additional_reply_to_emails = "a@example.com, b@example.com"
      expect(@email.reply_to_emails_to_store(user)).to eq("a@example.com, b@example.com")
    end

    it "deduplicates user email from additional emails" do
      @email.include_my_email = "1"
      @email.additional_reply_to_emails = "sender@example.com, a@example.com"
      result = @email.reply_to_emails_to_store(user)
      expect(result).to include("sender@example.com")
      expect(result).to include("a@example.com")
      expect(result.split(", ").length).to eq(2)
    end

    it "ignores blank additional emails" do
      @email.include_my_email = nil
      @email.additional_reply_to_emails = "a@example.com, , b@example.com"
      result = @email.reply_to_emails_to_store(user)
      expect(result).to eq("a@example.com, b@example.com")
    end
  end
end
