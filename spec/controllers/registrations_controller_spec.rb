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
      Rails.application.secrets.mail_skip_confirmation = nil
    end

    it "doesn't send an e-mail when skip configured" do
      Rails.application.secrets.mail_skip_confirmation = true
      post :create, valid_attributes
      u = User.first
      expect(u.confirmed?).to eq(true)
    end
    it "doesn't send an e-mail when the laptop is authorized" do
      allow_any_instance_of(RegistrationsController).to receive(:skip_user_creation_confirmation?).and_return true
      post :create, valid_attributes
      u = User.first
      expect(u.confirmed?).to eq(true)
    end
  end
end
