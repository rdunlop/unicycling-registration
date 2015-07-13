require 'spec_helper'

describe Admin::PermissionsController do
  before(:each) do
    @super_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_user
  end

  describe "GET index" do
    it "assigns all users as @users" do
      admin_user = FactoryGirl.create(:admin_user)
      user = FactoryGirl.create(:user)
      get :index, {}
      expect(assigns(:users)).to match_array([@super_user, admin_user, user])
    end
  end

  describe "PUT set_role" do
    describe "with a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end
      it "can change a user to an admin" do
        put :set_role, user_id: @user.to_param, role_name: :convention_admin
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(true)
      end
      it "can change an admin back to a user" do
        admin = FactoryGirl.create(:convention_admin_user)
        put :set_role, user_id: admin.to_param, role_name: :convention_admin
        expect(response).to redirect_to(permissions_path)
        admin.reload
        expect(admin.has_role?(:convention_admin)).to eq(false)
      end

      it "is not possible as a normal admin user" do
        user = FactoryGirl.create(:user)
        sign_out @super_user
        sign_in user

        put :set_role, user_id: @user.to_param, role_name: :convention_admin
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(false)
      end
    end
  end
end
