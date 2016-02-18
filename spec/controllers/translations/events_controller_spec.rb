require 'spec_helper'

describe Translations::EventsController do
  let!(:event) { FactoryGirl.create(:event) }
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
      get :edit, id: event.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => event.translations.first.id,
            "locale" => "en",
            "name" => "Slow Backward"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Slow thing"
          }
        }
      }
    end

    it "renders" do
      put :update, id: event.id, event: valid_attributes
      expect(response).to redirect_to(translations_events_path)
      I18n.locale = :fr
      expect(event.reload.name).to eq("Slow thing")
    end
  end
end
