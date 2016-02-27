require 'spec_helper'

describe ConventionSetup::ConventionSetupController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "GET costs" do
    it "renders" do
      get :costs
      expect(response).to be_success
    end
  end
end
