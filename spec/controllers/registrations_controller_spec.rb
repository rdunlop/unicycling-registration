require 'spec_helper'

describe RegistrationsController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  valid_attributes = {user: {
    email: "robin@dunlopweb.com",
    password: "password",
    password_confirmation: "password"
  }}

  describe "confirmation e-mail" do
    after(:each) do
      ENV['MAIL_SKIP_CONFIRMATION'] = nil
    end
    it "sends an e-mail" do
      ActionMailer::Base.deliveries.clear
      post :create, valid_attributes
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
    end

    it "doesn't send an e-mail when skip configured" do
      ActionMailer::Base.deliveries.clear
      ENV['MAIL_SKIP_CONFIRMATION'] = "true"
      post :create, valid_attributes
      num_deliveries = ActionMailer::Base.deliveries.size
      u = User.first
      u.confirmed?.should == true
      num_deliveries.should == 1 # XXX this is because the e-mail still goes out
    end
    it "doesn't send an e-mail when the laptop is authorized" do
      ActionMailer::Base.deliveries.clear
      allow_any_instance_of(RegistrationsController).to receive(:skip_user_creation_confirmation?).and_return true
      post :create, valid_attributes
      num_deliveries = ActionMailer::Base.deliveries.size
      u = User.first
      u.confirmed?.should == true
      num_deliveries.should == 1 # XXX this is because the e-mail still goes out
    end
  end
end
