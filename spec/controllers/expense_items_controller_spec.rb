require 'spec_helper'

describe ExpenseItemsController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:expense_item) { FactoryGirl.create(:expense_item) }

  describe "GET details" do
    it "displays the details" do
      get :details, id: expense_item.to_param
      expect(assigns(:expense_item)).to eq(expense_item)
    end
  end
end
