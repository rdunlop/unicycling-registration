require 'spec_helper'

describe SampleData::CompetitionsController do
  before do
    FactoryBot.create(:event)
    @user = FactoryBot.create(:super_admin_user)
    EventConfiguration.singleton.update(test_mode: true)
    sign_in @user
  end

  describe "GET index" do
    it do
      get :index
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    it "creates a competition" do
      expect do
        post :create, params: { competition_type: "Artistic Freestyle IUF 2017" }
      end.to change(Competition, :count).by(1)
    end
  end
end
