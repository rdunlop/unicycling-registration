require 'spec_helper'

describe SampleData::CompetitionsController do
  before(:each) do
    FactoryGirl.create(:event)
    @user = FactoryGirl.create(:super_admin_user)
    FactoryGirl.create(:event_configuration, test_mode: true)
    sign_in @user
  end

  describe "GET index" do
    it do
      get :index
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:params) { { competition_type: "Artistic Freestyle IUF 2015" } }
    it "creates a competition" do
      expect do
        post :create, params
      end.to change(Competition, :count).by(1)
    end
  end
end
