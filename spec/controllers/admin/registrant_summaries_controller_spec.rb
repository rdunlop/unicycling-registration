require 'spec_helper'

describe Admin::RegistrantSummariesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  context "with some registrants" do
    before do
      FactoryGirl.create_list(:registrant, 3)
    end

    describe "GET show_all" do
      it "renders in normal order" do
        post :create, format: :pdf
        expect(response).to redirect_to(reports_path)
      end

      it "renders in id order" do
        post :create, params: { order: "id" }, format: :pdf
        expect(response).to redirect_to(reports_path)
      end

      it "renders in id order with offset" do
        post :create, params: { order: "id", offset: "20", max: "5"}, format: :pdf
        expect(response).to redirect_to(reports_path)
      end
    end

    describe "GET index" do
      it "renders" do
        get :index
        expect(response).to be_success
      end
    end
  end
end
