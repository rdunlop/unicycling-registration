require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "with an admin user" do
    before(:each) do
      sign_out @user
      @admin_user = FactoryGirl.create(:admin_user)
      sign_in @admin_user
    end

    describe "GET manage_all" do
      it "assigns all registrants as @registrants" do
        registrant = FactoryGirl.create(:competitor)
        other_reg = FactoryGirl.create(:registrant)
        get :manage_all, {}
        expect(assigns(:registrants)).to match_array([registrant, other_reg])
      end
    end

    describe "POST undelete" do
      before(:each) do
        FactoryGirl.create(:registration_period)
      end
      it "un-deletes a deleted registration" do
        registrant = FactoryGirl.create(:competitor, deleted: true)
        post :undelete, id: registrant.to_param
        registrant.reload
        expect(registrant.deleted).to eq(false)
      end

      it "redirects to the root" do
        registrant = FactoryGirl.create(:competitor, deleted: true)
        post :undelete, id: registrant.to_param
        expect(response).to redirect_to(manage_all_registrants_path)
      end

      describe "as a normal user" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user
        end
        it "Cannot undelete a user" do
          registrant = FactoryGirl.create(:competitor, deleted: true)
          post :undelete, id: registrant.to_param
          registrant.reload
          expect(registrant.deleted).to eq(true)
        end
      end
    end
  end
end
