require 'spec_helper'

describe Admin::BagLabelsController do
  before do
    @admin_user = FactoryBot.create(:super_admin_user)
    sign_in @admin_user
  end

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    it "renders" do
      post :create, params: { label_type: "Avery8167" }
      expect(response).to be_successful
    end

    it "redirects with an alert when no label_type is chosen" do
      post :create
      expect(response).to redirect_to(bag_labels_path)
      expect(flash[:alert]).to be_present
    end
  end
end
