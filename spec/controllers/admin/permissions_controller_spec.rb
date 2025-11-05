require 'spec_helper'

describe Admin::PermissionsController do
  before do
    @super_user = FactoryBot.create(:super_admin_user)
    sign_in @super_user
  end

  describe "GET index" do
    it 'can display the page' do
      get :index
      assert_select "h1", "User Management"
    end
  end

  describe "PUT set_role" do
    describe "with a normal user" do
      before do
        @user = FactoryBot.create(:user)
        @user2 = FactoryBot.create(:user)
      end

      it "can change a user to an admin" do
        put :set_role, params: { users_id: [@user.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(true)
      end

      it "can change an admin back to a user" do
        admin = FactoryBot.create(:convention_admin_user)
        put :set_role, params: { users_id: [admin.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(permissions_path)
        admin.reload
        expect(admin.has_role?(:convention_admin)).to eq(false)
      end

      it "is not possible as a normal admin user" do
        user = FactoryBot.create(:user)
        sign_out @super_user
        sign_in user

        put :set_role, params: { users_id: [@user.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(false)
      end

      it "can add multiples roles to multiples users at once" do
        put :set_role, params: { users_id: [@user2.to_param, @user.to_param], roles_names: %i[payment_admin music_dj] }
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:payment_admin)).to eq(true)
        expect(@user.has_role?(:music_dj)).to eq(true)
        expect(@user2.has_role?(:payment_admin)).to eq(true)
        expect(@user2.has_role?(:music_dj)).to eq(true)
      end
    end
  end

  describe "PUT add_role" do
    describe "with a normal user" do
      before do
        @user = FactoryBot.create(:user)
        @user2 = FactoryBot.create(:user)
      end

      it "can make a user an admin" do
        put :add_role, params: { users_id: [@user.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(true)
      end

      it "can't change an admin back to a user" do
        admin = FactoryBot.create(:convention_admin_user)
        put :add_role, params: { users_id: [admin.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(permissions_path)
        admin.reload
        expect(admin.has_role?(:convention_admin)).to eq(true)
      end

      it "is not possible as a normal admin user" do
        user = FactoryBot.create(:user)
        sign_out @super_user
        sign_in user

        put :add_role, params: { users_id: [@user.to_param], roles_names: [:convention_admin] }
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(false)
      end

      it "can add multiples roles to multiples users at once" do
        put :add_role, params: { users_id: [@user2.to_param, @user.to_param], roles_names: %i[payment_admin music_dj] }
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:payment_admin)).to eq(true)
        expect(@user.has_role?(:music_dj)).to eq(true)
        expect(@user2.has_role?(:payment_admin)).to eq(true)
        expect(@user2.has_role?(:music_dj)).to eq(true)
      end
    end
  end

  describe "DELETE remove_roles" do
    describe "with a normal user" do
      before do
        @user = FactoryBot.create(:user)
        @user.add_role :convention_admin
        @user.add_role :payment_admin
        @user.add_role :music_dj
      end

      it "can remove a role from an user" do
        delete :remove_roles, params: { user_id: @user.to_param, roles: [:convention_admin] }
        expect(response).to redirect_to(permissions_path)
        @user.reload
        expect(@user.has_role?(:convention_admin)).to eq(false)
      end

      it "can remove multiple roles from an user" do
        delete :remove_roles, params: { user_id: @user.to_param, roles: %i[payment_admin music_dj] }
        expect(response).to redirect_to(permissions_path)
        expect(@user.has_role?(:payment_admin)).to eq(false)
        expect(@user.has_role?(:music_dj)).to eq(false)
      end
    end
  end

  describe "PUT set_password" do
    let(:user) { FactoryBot.create(:user) }
    let(:new_password) { "New Password" }

    before do
      user
      ActionMailer::Base.deliveries.clear
    end

    it "changes the users password" do
      put :set_password, params: { user_id: user.id, password: new_password }
      expect(user.reload).to be_valid_password(new_password)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    context "when the password is blank" do
      it "displays an error message" do
        put :set_password, params: { user_id: user.id, password: "" }
        expect(flash[:alert]).to match(/Invalid Password/)
      end
    end
  end
end
