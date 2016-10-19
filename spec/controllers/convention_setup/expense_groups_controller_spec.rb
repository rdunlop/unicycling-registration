require 'spec_helper'

describe ConventionSetup::ExpenseGroupsController do
  before(:each) do
    @admin = FactoryGirl.create(:super_admin_user)
    sign_in @admin
  end

  # This should return the minimal set of attributes required to create a valid
  # ExpenseGroup. As you add validations to ExpenseGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      info_url: "http://google.com",
      competitor_free_options: nil,
      noncompetitor_free_options: nil,
      competitor_required: false,
      noncompetitor_required: false,
      "translations_attributes" => {
        "1" => {
          "locale" => "en",
          "group_name" => "group_en"
        }}
    }
  end

  describe "GET index" do
    it "shows all expense_groups" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :index
      assert_select "h1", "Items For Sale"
      assert_select "tr>td", text: expense_group.to_s, count: 1
    end
  end

  describe "GET edit" do
    it "shows the expense_group form" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :edit, params: { id: expense_group.to_param }
      assert_select "form", action: expense_groups_path(expense_group), method: "post" do
        assert_select "input#expense_group_group_name", name: "expense_group[group_name]"
        assert_select "input#expense_group_info_url", name: "expense_group[info_url]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseGroup" do
        expect do
          post :create, params: { expense_group: valid_attributes }
        end.to change(ExpenseGroup, :count).by(1)
      end

      it "redirects to the created expense_group" do
        post :create, params: { expense_group: valid_attributes }
        expect(response).to redirect_to(expense_groups_path)
      end
    end

    describe "with invalid params" do
      it "does not create a new expense_group" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        expect do
          post :create, params: { expense_group: {info_url: "hi"} }
        end.not_to change(ExpenseGroup, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        post :create, params: { expense_group: {info_url: "hi"} }
        assert_select "h1", "Items For Sale"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        expect do
          put :update, params: { id: expense_group.to_param, expense_group: valid_attributes.merge(info_url: "hi there") }
        end.to change { expense_group.reload.info_url }
      end

      it "redirects to the expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        put :update, params: { id: expense_group.to_param, expense_group: valid_attributes }
        expect(response).to redirect_to(expense_groups_path)
      end
    end

    describe "with invalid params" do
      it "does not update the expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: expense_group.to_param, expense_group: {info_url: "fake"} }
        end.not_to change { expense_group.reload.info_url }
      end

      it "re-renders the 'edit' template" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        put :update, params: { id: expense_group.to_param, expense_group: {info_url: "hi"} }
        assert_select "h1", "#{expense_group} - Expense Group Details"
      end
    end
  end

  describe "PUT update_row_order" do
    let!(:expense_group_1) { FactoryGirl.create(:expense_group) }
    let!(:expense_group_2) { FactoryGirl.create(:expense_group) }

    it "updates the order" do
      put :update_row_order, params: { id: expense_group_1.to_param, row_order_position: 1 }
      expect(expense_group_2.reload.position).to eq(1)
      expect(expense_group_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      expect do
        delete :destroy, params: { id: expense_group.to_param }
      end.to change(ExpenseGroup, :count).by(-1)
    end

    it "redirects to the expense_groups list" do
      expense_group = ExpenseGroup.create! valid_attributes
      delete :destroy, params: { id: expense_group.to_param }
      expect(response).to redirect_to(expense_groups_url)
    end
  end
end
