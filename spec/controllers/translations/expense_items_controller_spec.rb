require 'spec_helper'

describe Translations::ExpenseItemsController do
  let!(:expense_item) { FactoryGirl.create(:expense_item) }
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
      get :edit, id: expense_item.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => expense_item.translations.first.id,
            "locale" => "en",
            "name" => "T-Shirt"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Le T-Shirt"
          }
        }
      }
    end

    it "renders" do
      put :update, id: expense_item.id, expense_item: valid_attributes
      expect(response).to redirect_to(translations_expense_items_path)
      I18n.locale = :fr
      expect(expense_item.reload.name).to eq("Le T-Shirt")
    end
  end
end
