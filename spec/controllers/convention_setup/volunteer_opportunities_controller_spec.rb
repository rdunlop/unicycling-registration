require 'spec_helper'

describe ConventionSetup::VolunteerOpportunitiesController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all coupon_codes as @coupon_codes" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      get :index, {}
      expect(response).to be_success
      expect(assigns(:volunteer_opportunities)).to eq([volunteer_opportunity])
    end
  end

  describe "DELETE destroy" do
    it "removes volunteer opportunity" do
      volunteer_opportunity = FactoryGirl.create(:volunteer_opportunity)
      expect do
        delete :destroy, id: volunteer_opportunity.id
      end.to change(VolunteerOpportunity, :count).by(-1)
    end
  end
end
