require 'spec_helper'

describe SampleData::RegistrantsController do
  before(:each) do
    @reg = FactoryGirl.create(:registrant) # so that WheelSizes are created
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
    it "creates a registrant" do
      expect do
        post :create, number: "1"
      end.to change(Registrant, :count).by(1)
    end
  end
end
