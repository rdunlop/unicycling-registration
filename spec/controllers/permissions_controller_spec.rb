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
      expect(assigns(:users)).to match_array([@super_user, admin_user, user])
    end
  end

  describe "PUT set_role" do
    describe "with a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end
      it "can change a user to an admin" do
        put :set_role, {:user_id => @user.to_param, :role_name => :admin}
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:admin)).to eq(true)
      end
      it "can change an admin back to a user" do
        admin = FactoryGirl.create(:admin_user)
        put :set_role, {:user_id => admin.to_param, :role_name => :admin}
        expect(response).to redirect_to(permissions_path)
        admin.reload
        expect(admin.has_role?(:admin)).to eq(false)
      end

      it "is not possible as a normal admin user" do
        admin_user = FactoryGirl.create(:admin_user)
        sign_out @super_user
        sign_in admin_user

        put :set_role, {:user_id => @user.to_param, :role_name => :admin}
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.has_role?(:admin)).to eq(false)
      end
    end
  end

  describe "when signed out" do
    before :each do
      sign_out @super_user
    end

    it "can access the acl page" do
      get :acl
      expect(response).to be_success
    end

    it "can authorize acl" do
      allow_any_instance_of(ApplicationController).to receive(:modification_access_key).and_return(123456)
      post :set_acl, {access_key: "123456"}
      expect(flash[:notice]).to eq("Successfully Enabled Access")
    end

    describe "can use an access code" do
      let!(:registrant) { FactoryGirl.create(:registrant) }
      let(:access_code) { registrant.access_code }

      it "can use the access code" do
        expect {
          post :use_code, { registrant_id: registrant.id, code: access_code }
        }.to change(User, :count).by(1)
      end

      it "doesn't succeed if the access code is invalid" do
        expect {
          post :use_code, { registrant_id: registrant.id, code: "invalid_code" }
        }.to_not change(User, :count)
      end

      it "doesn't create another guest if one already exists" do
        post :use_code, { registrant_id: registrant.id, code: access_code }
        expect {
          post :use_code, { registrant_id: registrant.id, code: access_code }
        }.to_not change(User, :count)
      end
    end
  end
end
