require 'spec_helper'

describe AdminUpgradesController do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "GET new" do
    it "renders" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    context "with incorrect code" do
      it "raises exception" do
        post :create, params: { access_code: "wrong" }
        expect(response).to redirect_to(root_path) # because not authorized
      end
    end

    context "with correct code" do
      it "upgrades user" do
        post :create, params: { access_code: "TEST_UPGRADE_CODE" }
        expect(user.reload).to have_role(:convention_admin)
      end
    end

    context "with super-admin code" do
      around do |example|
        old = Rails.configuration.super_admin_upgrade_code
        Rails.configuration.super_admin_upgrade_code = "super"
        example.call
        Rails.configuration.super_admin_upgrade_code = old
      end

      it "upgrades user to super-admin" do
        post :create, params: { access_code: "super" }
        expect(user.reload).to have_role(:super_admin)
      end
    end
  end
end
