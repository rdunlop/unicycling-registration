require 'spec_helper'

describe PermissionsController do
  describe "when signed out" do
    it "can access the acl page" do
      get :acl
      expect(response).to be_successful
    end

    it "can authorize acl" do
      allow_any_instance_of(ApplicationController).to receive(:modification_access_key).and_return(123456)
      post :set_acl, params: { access_key: "123456" }
      expect(flash[:notice]).to eq("Successfully Enabled Access")
    end

    describe "can use an access code" do
      let!(:registrant) { FactoryBot.create(:registrant) }
      let(:access_code) { registrant.access_code }

      it "can use the access code" do
        expect do
          post :use_code, params: { registrant_id: registrant.id, code: access_code }
        end.to change(User, :count).by(1)
      end

      it "doesn't succeed if the access code is invalid" do
        expect do
          post :use_code, params: { registrant_id: registrant.id, code: "invalid_code" }
        end.not_to change(User, :count)
      end

      it "doesn't create another guest if one already exists" do
        post :use_code, params: { registrant_id: registrant.id, code: access_code }
        expect do
          post :use_code, params: { registrant_id: registrant.id, code: access_code }
        end.not_to change(User, :count)
      end
    end

    describe "can view volunteer sign-in page" do
      it "shows the page" do
        get :volunteer
        expect(response).to be_successful
      end
    end
  end
end
