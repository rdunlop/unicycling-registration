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
      post :create
      expect(response).to be_successful
    end
  end
end
