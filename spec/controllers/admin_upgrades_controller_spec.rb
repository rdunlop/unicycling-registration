require 'spec_helper'

describe AdminUpgradesController do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    sign_in user
  end

  describe "GET new" do
    it "renders" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST create" do
    context "with incorrect code" do
      it "raises exception" do
        post :create, access_code: "wrong"
        expect(response).to redirect_to(root_path) # because not authorized
      end
    end

    context "with correct code" do
      it "upgrades user" do
        post :create, access_code: nil # tests don't have a stored Tenant, so `nil` is the access_code of a new object
        expect(user.reload.has_role?(:convention_admin)).to be_truthy
      end
    end
  end
end
