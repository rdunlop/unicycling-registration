require 'spec_helper'

describe HeatExportsController do
  let(:competition) { FactoryGirl.create(:timed_competition) }

  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET index" do
    it "can view" do
      get :index, params: { competition_id: competition.id }
      expect(response).to be_success
    end
  end

  describe "GET download_competitor_list_ssv" do
    it "renders" do
      get :download_competitor_list_ssv, params: { competition_id: competition.id }
      assert_equal "text/csv", @response.content_type
    end
  end

  describe "GET download_heat_tsv" do
    it "renders data" do
      get :download_heat_tsv, params: { competition_id: competition.id }
      assert_equal "text/csv", @response.content_type
    end
  end
end
