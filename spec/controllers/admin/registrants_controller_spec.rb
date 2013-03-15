require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
  end


  describe "GET index" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor)
      other_reg = FactoryGirl.create(:registrant)
      get :index, {}
      assigns(:registrants).should eq([registrant, other_reg])
    end
  end

  describe "POST undelete" do
    it "un-deletes a deleted registration" do
      registrant = FactoryGirl.create(:competitor, :deleted => true)
      post :undelete, {:id => registrant.id }
      registrant.reload
      registrant.deleted.should == false
    end

    it "redirects to the index" do
      registrant = FactoryGirl.create(:competitor, :deleted => true)
      post :undelete, {:id => registrant.id }
      response.should redirect_to(admin_registrants_path)
    end

    describe "as a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      it "Cannot undelete a user" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.id }
        registrant.reload
        registrant.deleted.should == true
      end
    end
  end

end
