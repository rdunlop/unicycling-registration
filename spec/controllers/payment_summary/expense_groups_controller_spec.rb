require 'spec_helper'

describe PaymentSummary::ExpenseGroupsController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:expense_group) { FactoryGirl.create(:expense_group) }

  describe "GET show" do
    let!(:expense_item) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "displays the items" do
      get :show, params: { id: expense_group.to_param }
      assert_select "h2", "Expense Items for #{expense_group}"
      assert_select "td", expense_item.to_s
    end
  end
end
