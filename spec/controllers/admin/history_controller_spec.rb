require 'spec_helper'

describe Admin::HistoryController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end

  describe "GET index" do
    it "assigns all versions as @versions" do
      get :index, {}
      response.should be_success
      assigns(:versions).should eq([])
    end
  end
end
