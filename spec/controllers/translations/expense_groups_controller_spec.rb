require 'spec_helper'

describe Translations::ExpenseGroupsController do
  let!(:expense_group) { FactoryGirl.create(:expense_group) }
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
      get :edit, id: expense_group.id
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => expense_group.translations.first.id,
            "locale" => "en",
            "group_name" => "T-Shirts"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "group_name" => "Le T-Shirts"
          }
        }
      }
    end

    it "renders" do
      put :update, id: expense_group.id, expense_group: valid_attributes
      expect(response).to redirect_to(translations_expense_groups_path)
      I18n.locale = :fr
      expect(expense_group.reload.group_name).to eq("Le T-Shirts")
    end
  end
end
