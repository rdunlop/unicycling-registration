require 'spec_helper'

describe WelcomeController do
  let(:user) { FactoryBot.create(:user) }

  describe "GET 'help'" do
    context "When not logged in" do
      it "returns http success" do
        get :help
        expect(response).to be_successful

        assert_match(/Help/, response.body)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "returns http success" do
        get :help
        expect(response).to be_successful

        assert_match(/Help/, response.body)
      end
    end
  end

  describe "GET index with a locale which is not enabled for this convention" do
    before { FactoryBot.create(:event_configuration, enabled_locales: %w[en fr]) }

    it "ignores the locale and uses the default" do
      expect { get :index, params: { locale: "es" } }.not_to raise_error
      expect(I18n.locale).to eq(:en)
    end

    it "does not change the globally available locales" do
      get :index, params: { locale: "fr" }
      expect(I18n.available_locales).to eq(I18n.config.available_locales)
    end
  end

  describe "GET changelog" do
    it "returns http success" do
      get :changelog
      expect(response).to be_successful
    end
  end

  describe "GET help_translate" do
    it "returns http success" do
      get :help_translate
      expect(response).to be_successful
    end
  end

  describe "GET index" do
    describe "when there is a 'Home' page" do
      let!(:home_page) { FactoryBot.create(:page, :home) }

      it "redirects to homepage" do
        get :index
        expect(response).to redirect_to(page_path(home_page.slug))
      end
    end

    describe "when there is no 'Home' page" do
      it "redirects to log_in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # handle case where a machine queries for a non-locale
  describe "GET 'humans.txt'" do
    it "returns 404-not-found" do
      sign_in user
      expect do
        get :index, params: { locale: 'humans' }, format: 'txt'
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
