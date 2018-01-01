require 'spec_helper'

describe ConventionSetup::ExpenseItemsController do
  before(:each) do
    @admin = FactoryGirl.create(:super_admin_user)
    sign_in @admin
  end

  let(:expense_group) { FactoryGirl.create(:expense_group) }
  let(:expense_item) { FactoryGirl.create :expense_item, expense_group: expense_group }

  # This should return the minimal set of attributes required to create a valid
  # ExpenseItem. As you add validations to ExpenseItem, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      translations_attributes: {
        "1" => {
          locale: "en",
          name: "Small T-Shirt",
          details_label: nil
        }
      },
      cost: 15.00,
      has_details: false,
      position: 1,
      tax: 0,
      maximum_available: nil
    }
  end

  describe "GET index" do
    it "shows all expense_items" do
      expense_item
      get :index, params: { expense_group_id: expense_group.id }

      assert_select "table#list" do
        assert_select "tr>td", text: expense_item.name.to_s, count: 1
        assert_select "tr>td", text: expense_item.cost.to_s, count: 2 # one for the cost, one for total_cost
      end

      assert_select "form", action: expense_group_expense_items_path(expense_group), method: "post" do
        assert_select "input#expense_item_cost", name: "expense_item[cost]"
        assert_select "input#expense_item_has_details", name: "expense_item[has_details]"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested expense_item form" do
      get :edit, params: { id: expense_item.to_param, expense_group_id: expense_group.id }
      assert_select "form", action: expense_group_expense_items_path(expense_group, expense_item), method: "post" do
        assert_select "input#expense_item_has_details", name: "expense_item[has_details]"
        assert_select "input#expense_item_cost", name: "expense_item[cost]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseItem" do
        expect do
          post :create, params: { expense_item: valid_attributes, expense_group_id: expense_group.id }
        end.to change(ExpenseItem, :count).by(1)
      end

      it "redirects to the created expense_item" do
        post :create, params: { expense_item: valid_attributes, expense_group_id: expense_group.id }
        expect(response).to redirect_to(expense_group_expense_items_path(expense_group))
      end
      it "sets the maximum_per_registrant" do
        post :create, params: { expense_group_id: expense_group.id, expense_item: valid_attributes.merge(maximum_per_registrant: 1) }
        expect(ExpenseItem.last.maximum_per_registrant).to eq(1)
      end
    end

    describe "with invalid params" do
      it "does not create a new expense_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        expect do
          post :create, params: { expense_item: {position: 1}, expense_group_id: expense_group.id }
        end.not_to change(ExpenseItem, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        post :create, params: { expense_item: {position: 1}, expense_group_id: expense_group.id }
        assert_select "h1", "Listing #{expense_group} expense items"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense_item" do
        expect do
          put :update, params: { id: expense_item.to_param, expense_item: valid_attributes.merge(cost: 20), expense_group_id: expense_group.id }
        end.to change { expense_item.reload.cost }
      end

      it "redirects to the expense_item" do
        put :update, params: { id: expense_item.to_param, expense_item: valid_attributes, expense_group_id: expense_group.id }
        expect(response).to redirect_to(expense_group_expense_items_path(expense_group))
      end
    end

    describe "with invalid params" do
      it "does not update the expense_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: expense_item.to_param, expense_item: {position: 1, cost: 20}, expense_group_id: expense_group.id }
        end.not_to change { expense_item.reload.cost }
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        put :update, params: { id: expense_item.to_param, expense_item: {position: 1}, expense_group_id: expense_group.id }
        assert_select "h1", "Editing Expense Item"
      end
    end
  end

  describe "PUT update_row_order" do
    let!(:expense_item_1) { FactoryGirl.create(:expense_item, expense_group: expense_group) }
    let!(:expense_item_2) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "updates the order" do
      put :update_row_order, params: { id: expense_item_1.to_param, row_order_position: 1 }
      expect(expense_item_2.reload.position).to eq(1)
      expect(expense_item_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_item" do
      expense_item
      expect do
        delete :destroy, params: { id: expense_item.to_param, expense_group_id: expense_group.id }
      end.to change(ExpenseItem, :count).by(-1)
    end

    it "redirects to the expense_items list" do
      delete :destroy, params: { id: expense_item.to_param, expense_group_id: expense_group.id }
      expect(response).to redirect_to(expense_group_expense_items_url(expense_group))
    end

    context "with an associated payment_detail" do
      before do
        FactoryGirl.create(:payment_detail, line_item: expense_item)
      end

      it "does not destroy the expense_item" do
        expect { delete :destroy, params: { id: expense_item.to_param, expense_group_id: expense_group.id } }.to raise_error(ActiveRecord::DeleteRestrictionError)
        expect(ExpenseItem.find_by(id: expense_item.id)).not_to be_nil
      end
    end
  end
end
