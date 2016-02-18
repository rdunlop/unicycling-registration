require 'spec_helper'

describe Translations::PagesController do
  let!(:page) { FactoryGirl.create(:page) }
  let(:user) { FactoryGirl.create(:convention_admin_user) }

  before { sign_in user }
  after { I18n.locale = :en }

  describe "#index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#edit" do
    it "renders" do
      get :edit, id: page.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => page.translations.first.id,
            "locale" => "en",
            "title" => "Lodging"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "title" => "Le Lodging"
          }
        }
      }
    end

    it "renders" do
      put :update, id: page.id, page: valid_attributes
      expect(response).to redirect_to(translations_pages_path)
      I18n.locale = :fr
      expect(page.reload.title).to eq("Le Lodging")
    end
  end
end
