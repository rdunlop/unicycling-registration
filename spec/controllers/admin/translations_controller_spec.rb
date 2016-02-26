require 'spec_helper'

describe Admin::TranslationsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:convention_admin_user)
    sign_in @admin_user
  end

  describe "DELETE clear_cache" do
    it "can clear the translation cache" do
      delete :clear_cache
      expect(response).to redirect_to(translations_path)
    end
  end
end
