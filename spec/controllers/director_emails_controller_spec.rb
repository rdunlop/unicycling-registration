require 'spec_helper'

describe DirectorEmailsController do
  before(:each) do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  describe "GET new" do
    it "can view the page" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST send_email" do
    it "can send an e-mail" do
      FactoryBot.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, params: { email: { subject: "Hello werld", body: "This is the body" } }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
      expect(MassEmail.count).to eq(1)
      message = ActionMailer::Base.deliveries.first
      expect(message.bcc.count).to eq(1)
    end
  end
end
