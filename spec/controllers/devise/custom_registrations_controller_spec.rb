require 'spec_helper'

describe Devise::CustomRegistrationsController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  valid_attributes = {
    email: "robin@dunlopweb.com",
    password: "password",
    password_confirmation: "password"
  }

  describe "confirmation e-mail" do
    after(:each) do
      Rails.application.secrets.mail_skip_confirmation = nil
    end

    it "doesn't send an e-mail when skip configured" do
      Rails.application.secrets.mail_skip_confirmation = true
      post :create, params: { user: valid_attributes }
      u = User.first
      expect(u.confirmed?).to eq(true)
    end
    it "doesn't send an e-mail when the laptop is authorized" do
      allow_any_instance_of(described_class).to receive(:skip_user_creation_confirmation?).and_return true
      post :create, params: { user: valid_attributes }
      u = User.first
      expect(u.confirmed?).to eq(true)
    end
  end

  describe "already have an account" do
    let(:email) { "bob@example.com" }
    let(:password) { "password" }
    let!(:user) { User.create!(confirmed_at: 1.day.ago, email: email, password: password, password_confirmation: password) }

    it "redirects to the sign-in path automatically" do
      post :create, params: { user: { email: email, password: password, password_confirmation: password } }
      expect(response).to redirect_to(new_user_session_path(user: { email: email }))
    end
  end

  describe "when updating the password" do
    let(:initial_password) { "start password" }
    let(:user) { FactoryGirl.create(:user, confirmed_at: 1.day.ago, email: valid_attributes[:email], password: initial_password, password_confirmation: initial_password) }
    let!(:user_convention) { user.user_conventions.first }

    it "clears all legacy_passwords" do
      sign_in user
      put :update, params: { user: valid_attributes.merge(current_password: initial_password) }
      expect(user_convention.reload.legacy_encrypted_password).to be_nil
      expect(user.reload.valid_password?("password")).to be_truthy
    end
  end
end
