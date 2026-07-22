require 'spec_helper'

describe EmailsController do
  before do
    @user = FactoryBot.create(:super_admin_user)
    EventConfiguration.singleton.update(contact_email: "contact@example.com")
    sign_in @user
  end

  describe "GET index" do
    it "can view the page" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET list" do
    it "can view the page" do
      get :list, params: { filter_email: { filter: "confirmed_accounts" } }
      expect(response).to be_successful
    end

    it "includes the checkbox for include_my_email" do
      get :list, params: { filter_email: { filter: "confirmed_accounts" } }
      expect(response.body).to include("Include my email in the reply-to list")
      expect(response.body).to include("mass-email-reply-to")
    end

    it "includes the text field for additional_reply_to_emails" do
      get :list, params: { filter_email: { filter: "confirmed_accounts" } }
      expect(response.body).to include("Additional reply-to emails")
    end
  end

  describe "GET download" do
    it "can view the page" do
      get :download
      expect(response).to be_successful
    end
  end

  describe "GET sent" do
    it "can view the page" do
      mass_email = FactoryBot.create(:mass_email)
      get :sent, params: { id: mass_email.id }
      expect(response).to be_successful
    end

    it "shows contact email in reply-to section" do
      mass_email = FactoryBot.create(:mass_email)
      get :sent, params: { id: mass_email.id }
      expect(response.body).to include("Reply-To: Contact Email")
      expect(response.body).to include(EventConfiguration.singleton.contact_email)
    end

    it "shows additional emails when present" do
      mass_email = FactoryBot.create(:mass_email, additional_reply_to_emails: "extra@example.com, another@example.com")
      get :sent, params: { id: mass_email.id }
      expect(response.body).to include("Reply-To: Additional Emails")
      expect(response.body).to include("extra@example.com, another@example.com")
    end
  end

  describe "GET all_sent" do
    it "can view the page" do
      get :all_sent
      expect(response).to be_successful
    end
  end

  describe "POST send_email" do
    it "can send an e-mail" do
      FactoryBot.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body" }, filter: "confirmed_accounts", arguments: "" }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
      expect(MassEmail.count).to eq(1)
      message = ActionMailer::Base.deliveries.first
      expect(message.bcc.count).to eq(2)
    end

    it "breaks apart large requests into multiple smaller requests" do
      FactoryBot.create_list(:user, 50)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body" }, filter: "confirmed_accounts", arguments: "" }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(2)

      first_message = ActionMailer::Base.deliveries.first
      expect(first_message.bcc.count).to eq(40)

      second_message = ActionMailer::Base.deliveries.second
      expect(second_message.bcc.count).to eq(11) # 10 remaining from 50, plus 1 super_admin (self)
    end

    it "includes user email in reply-to when checkbox is checked" do
      FactoryBot.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body", include_my_email: "1" }, filter: "confirmed_accounts", arguments: "" }
      message = ActionMailer::Base.deliveries.first
      expect(message.reply_to).to include(@user.email)
    end

    it "includes additional reply-to emails" do
      FactoryBot.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body", additional_reply_to_emails: "extra@example.com" }, filter: "confirmed_accounts", arguments: "" }
      message = ActionMailer::Base.deliveries.first
      expect(message.reply_to).to include("extra@example.com")
    end

    it "stores additional_reply_to_emails on the mass_email" do
      FactoryBot.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body", additional_reply_to_emails: "a@example.com, b@example.com" }, filter: "confirmed_accounts", arguments: "" }
      mass_email = MassEmail.last
      expect(mass_email.additional_reply_to_emails).to eq("a@example.com, b@example.com")
    end
  end
end
