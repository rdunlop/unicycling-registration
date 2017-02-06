require 'spec_helper'

describe Devise::CustomPasswordsController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  valid_attributes = {
    password: "password",
    password_confirmation: "password"
  }

  describe "when updating the password" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_convention) { user.user_conventions.first }

    before do
      user_convention.update(legacy_encrypted_password: user.encrypted_password) # set _a_ password
      raw, enc = Devise.token_generator.generate(user.class, :reset_password_token)
      user.reset_password_token   = enc
      user.reset_password_sent_at = Time.now.utc
      user.save(validate: false)
      @token = raw
    end

    it "can sign in with new password" do
      put :update, params: { user: valid_attributes.merge(reset_password_token: @token) }
      expect(user.reload.valid_password?("password")).to be_truthy
    end

    it "does NOT clear all legacy_passwords" do
      put :update, params: { user: valid_attributes.merge(reset_password_token: @token) }
      expect(user_convention.reload.legacy_encrypted_password).not_to be_nil
    end
  end
end
