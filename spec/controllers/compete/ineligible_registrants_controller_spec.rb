require 'spec_helper'

describe Compete::IneligibleRegistrantsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  describe "GET index" do
    let!(:registrant) { FactoryGirl.create(:registrant, ineligible: true) }

    it "displays all ineligible registrants" do
      get :index
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let!(:registrant) { FactoryGirl.create(:registrant) }

    it "marks registrant as ineligible" do
      post :create, params: { registrant_id: registrant.id }
      expect(registrant.reload).to be_ineligible
    end
  end

  describe "DELETE destroy" do
    let!(:registrant) { FactoryGirl.create(:registrant, ineligible: true) }

    it "marks registrant as eligible" do
      delete :destroy, params: { id: registrant.id }
      expect(registrant.reload).not_to be_ineligible
    end
  end
end
