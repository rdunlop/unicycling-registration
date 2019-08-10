require 'spec_helper'

describe Admin::TranslationsController do
  before do
    @admin_user = FactoryBot.create(:convention_admin_user)
    sign_in @admin_user
  end

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "DELETE clear_cache" do
    it "can clear the translation cache" do
      delete :clear_cache
      expect(response).to redirect_to(translations_path)
    end
  end
end
