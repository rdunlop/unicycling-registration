require 'spec_helper'

describe Translations::EventCategoriesController do
  let!(:event_category) { FactoryGirl.create(:event_category) }
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
      get :edit, params: { id: event_category.id }
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => event_category.translations.first.id,
            "locale" => "en",
            "name" => "Team Name"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Le Team Name"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: event_category.id, event_category: valid_attributes }
      expect(response).to redirect_to(translations_event_categories_path)
      I18n.locale = :fr
      expect(event_category.reload.name).to eq("Le Team Name")
    end
  end
end
