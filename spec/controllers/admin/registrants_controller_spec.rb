require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end


  describe "GET index" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      other_reg = FactoryGirl.create(:registrant)
      get :index, {}
      assigns(:registrants).should eq([registrant, other_reg])
    end
  end

end
