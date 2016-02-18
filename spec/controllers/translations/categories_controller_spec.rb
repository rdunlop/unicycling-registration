require 'spec_helper'

describe Translations::CategoriesController do
  let!(:category) { FactoryGirl.create(:category) }
  let(:user) { FactoryGirl.create(:convention_admin_user) }

  before { sign_in user }

  describe "#index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#edit" do
    it "renders" do
      get :edit, id: category.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => category.translations.first.id,
            "locale" => "en",
            "name" => "Track Racing"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Le Track"
          }
        }
      }
    end

    it "renders" do
      put :update, id: category.id, category: valid_attributes
      expect(response).to redirect_to(translations_categories_path)
      I18n.locale = :fr
      expect(category.reload.name).to eq("Le Track")
    end
  end
end
