require 'spec_helper'

describe LabelTestPrintsController do
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

  describe "GET print" do
    it "renders a PDF with gridlines" do
      get :print, params: { label_type: "Avery8293" }
      expect(response).to be_successful
    end

    it "redirects with an alert when no label_type is chosen" do
      get :print
      expect(response).to redirect_to(label_test_prints_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "GET ruler" do
    it "renders a ruler-only PDF" do
      get :ruler
      expect(response).to be_successful
    end

    it "accepts a paper_size param" do
      get :ruler, params: { paper_size: "A4" }
      expect(response).to be_successful
    end
  end
end
