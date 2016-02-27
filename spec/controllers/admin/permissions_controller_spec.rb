require 'spec_helper'

describe Admin::PermissionsController do
  before(:each) do
    @super_user = FactoryGirl.create(:super_admin_user)
    sign_in @super_user
  end

  describe "GET index" do
    it "assigns all users as @users" do
      convention_admin_user = FactoryGirl.create(:convention_admin_user)
      user = FactoryGirl.create(:user)
      get :index, {}
      expect(assigns(:users)).to match_array([@super_user, convention_admin_user, user])
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

  describe "PUT set_password" do
    let(:user) { FactoryGirl.create(:user) }
    let(:new_password) { "New Password" }

    before do
      user
      ActionMailer::Base.deliveries.clear
    end

    it "changes the users password" do
      put :set_password, user_id: user.id, password: new_password
      expect(user.reload.valid_password?(new_password)).to be_truthy
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
