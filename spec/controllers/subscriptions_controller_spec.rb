require 'spec_helper'

describe SubscriptionsController do
  before do
    @opt_out = FactoryBot.create(:mail_opt_out)
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  describe "GET index" do
    it "show all opt outs" do
      get :index
      assert_select "tr>td", text: @opt_out.email, count: 1
    end
  end

  describe "POST subscribe" do
    describe "with valid params" do
      it "re-subscribes" do
        expect do
          post :subscribe, params: { id: @opt_out.id }
        end.to change { @opt_out.reload.opted_out }
      end
    end

    describe "with invalid params" do
      it "does not do anything" do
        # Trigger the behavior that occurs when invalid params are submitted
        expect do
          post :subscribe, params: { id: -1 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
