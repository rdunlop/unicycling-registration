require 'spec_helper'

describe SubscriptionsController do
  before do
    @opt_out = FactoryBot.create(:mail_opt_out)
    # @user = FactoryBot.create(:user)
    # sign_in @user
  end

  describe "GET index" do
    it "show all opt outs" do
      get :index
      assert_select "tr>td", text: @mail_opt_out.email, count: 1
    end
  end

  describe "POST subscribe" do
    describe "with valid params" do
      it "re-subscribes" do
        expect do
          post :subsrcibe, params: { id: @out_opt.id }
        end.to change { @opt_out.reload.opted_out }
      end
    end

    describe "with invalid params" do
      it "does not do anything" do
        # Trigger the behavior that occurs when invalid params are submitted
        expect do
          post :create, params: { id: -1 }
        end.not_to change { @opt_out.reload.attributes }
      end
    end
  end
end
