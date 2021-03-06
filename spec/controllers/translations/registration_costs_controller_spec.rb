require 'spec_helper'

describe Translations::RegistrationCostsController do
  let!(:registration_cost) { FactoryBot.create(:registration_cost) }
  let(:user) { FactoryBot.create(:convention_admin_user) }

  before { sign_in user }

  after { I18n.locale = :en }

  describe "#index" do
    it "renders" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#edit" do
    it "renders" do
      get :edit, params: { id: registration_cost.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => registration_cost.translations.first.id,
            "locale" => "en",
            "name" => "Early"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Pretot"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: registration_cost.id, registration_cost: valid_attributes }
      expect(response).to redirect_to(translations_registration_costs_path)
      I18n.locale = :fr
      expect(registration_cost.reload.name).to eq("Pretot")
    end
  end
end
