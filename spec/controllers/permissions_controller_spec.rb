require 'spec_helper'

describe PermissionsController do
  describe "when signed out" do

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
