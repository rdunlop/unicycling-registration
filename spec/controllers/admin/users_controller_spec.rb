require 'spec_helper'

describe Admin::UsersController do
  before(:each) do
    @super_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_user
  end

  describe "GET index" do
    it "assigns all users as @users" do
      admin_user = FactoryGirl.create(:admin_user)
      user = FactoryGirl.create(:user)
      get :index, {}
      assigns(:users).should =~ [@super_user, admin_user, user]
    end
  end

  describe "PUT admin" do
    describe "with a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end
      it "can change a user to an admin" do
        put :admin, {:id => @user.to_param}
        response.should redirect_to(admin_users_path)
        @user.reload
        @user.has_role?(:admin).should == true
      end
      it "can change an admin back to a user" do
        admin = FactoryGirl.create(:admin_user)
        put :admin, {:id => admin.to_param}
        response.should redirect_to(admin_users_path)
        admin.reload
        admin.has_role?(:admin).should == false
      end

      it "is not possible as a normal admin user" do
        admin_user = FactoryGirl.create(:admin_user)
        sign_out @super_user
        sign_in admin_user

        put :admin, {:id => @user.to_param}
        response.should redirect_to(root_path)
        @user.reload
        @user.has_role?(:admin).should == false
      end
    end
  end

end
