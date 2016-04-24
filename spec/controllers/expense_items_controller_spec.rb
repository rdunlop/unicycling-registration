# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean          default(FALSE), not null
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE), not null
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer          default(0), not null
#  cost_element_id        :integer
#  cost_element_type      :string
#
# Indexes
#
#  index_expense_items_expense_group_id                          (expense_group_id)
#  index_expense_items_on_cost_element_type_and_cost_element_id  (cost_element_type,cost_element_id)
#

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

    context "with a coupon-code applied" do
      let!(:expense_item_coupon_code) { FactoryGirl.create(:coupon_code_expense_item, expense_item: expense_item) }

      it "displays the details" do
        get :details, id: expense_item.to_param
        expect(assigns(:expense_item)).to eq(expense_item)
      end
    end
  end
end
