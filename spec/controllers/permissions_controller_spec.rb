require 'spec_helper'

describe PermissionsController do
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

  describe "PUT set_role" do
    describe "with a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end
      it "can change a user to an admin" do
        put :set_role, {:user_id => @user.to_param, :role_name => :admin}
        response.should redirect_to(permissions_path)
        @user.reload
        @user.has_role?(:admin).should == true
      end
      it "can change an admin back to a user" do
        admin = FactoryGirl.create(:admin_user)
        put :set_role, {:user_id => admin.to_param, :role_name => :admin}
        response.should redirect_to(permissions_path)
        admin.reload
        admin.has_role?(:admin).should == false
      end

      it "is not possible as a normal admin user" do
        admin_user = FactoryGirl.create(:admin_user)
        sign_out @super_user
        sign_in admin_user

        put :set_role, {:user_id => @user.to_param, :role_name => :admin}
        response.should redirect_to(root_path)
        @user.reload
        @user.has_role?(:admin).should == false
      end
    end
  end

  describe "when signed out" do
    before :each do
      sign_out @super_user
    end

    it "can access the acl page" do
      get :acl
      response.should be_success
    end

    it "can authorize acl" do
      allow_any_instance_of(ApplicationController).to receive(:modification_access_key).and_return("the_key")
      post :set_acl, {access_key: "the_key"}
      flash[:notice].should == "Successfully Enabled Access"
    end
  end
end
