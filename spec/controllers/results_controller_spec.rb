require 'spec_helper'

describe ResultsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let(:registrant) { FactoryGirl.create(:competitor) }
  let(:competition) { FactoryGirl.create(:competition) }

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "GET registrant" do
    it "renders" do
      get :registrant, registrant_id: registrant.id
      expect(response).to redirect_to(results_registrant_path(registrant))
    end
  end

  describe "GET scores" do
    let(:competition) { FactoryGirl.create(:competition, :combined) }
    it "renders" do
      get :scores, id: competition.id
      expect(response).to be_success
    end
  end
end
