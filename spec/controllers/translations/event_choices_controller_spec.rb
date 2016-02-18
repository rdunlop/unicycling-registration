require 'spec_helper'

describe Translations::EventChoicesController do
  let!(:event_choice) { FactoryGirl.create(:event_choice) }
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
      get :edit, id: event_choice.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => event_choice.translations.first.id,
            "locale" => "en",
            "label" => "Team"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "label" => "Equipe"
          }
        }
      }
    end

    it "renders" do
      put :update, id: event_choice.id, event_choice: valid_attributes
      expect(response).to redirect_to(translations_event_choices_path)
      I18n.locale = :fr
      expect(event_choice.reload.label).to eq("Equipe")
    end
  end
end
