require 'spec_helper'

describe Admin::ApiTokensController do
  let(:user) { FactoryBot.create(:super_admin_user) }
  let!(:token) { FactoryBot.create(:api_token) }

  before do
    sign_in user
  end

  describe "#index" do
    it "can list the tokens" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#create" do
    context "with good params" do
      it "can resolve the feedback" do
        expect do
          post :create, params: { api_token: { description: "This is Robin's" } }
        end.to change { ApiToken.count }.to(2)
        expect(response).to redirect_to(new_api_token_path)
      end
    end

    context "missing the description" do
      it "re-renders the new view" do
        post :create, params: { api_token: { description: "" } }
        expect(response).to be_successful
      end
    end
  end

  describe "#destroy" do
    it "deletes" do
      delete :destroy, params: { id: token.id }
      expect(response).to be_successful
    end
  end
end
