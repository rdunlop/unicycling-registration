require 'spec_helper'

describe ConventionSetup::ConventionSetupController do
  before do
    user = FactoryBot.create(:super_admin_user)
    sign_in user
  end

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET costs" do
    it "renders" do
      get :costs
      expect(response).to be_successful
    end
  end
end
