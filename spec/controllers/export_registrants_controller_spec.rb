require 'spec_helper'

describe ExportRegistrantsController do
  let!(:registrant) { FactoryGirl.create(:registrant) }
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "#download_all" do
    it "renders" do
      get :download_all
      expect(response).to be_success
    end
  end

  describe "#download_with_payment_details" do
    it "renders" do
      get :download_with_payment_details
      expect(response).to be_success
    end
  end
end
