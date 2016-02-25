require 'spec_helper'

describe ConventionSetup::ExpenseItemsController do
  before(:each) do
    @admin = FactoryGirl.create(:super_admin_user)
    sign_in @admin

    @expense_group = FactoryGirl.create(:expense_group)
  end

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
    it "assigns all expense_items as @expense_items" do
      expense_item = FactoryGirl.create :expense_item, expense_group: @expense_group
      get :index, expense_group_id: @expense_group.id
      expect(assigns(:expense_items)).to eq([expense_item])
      expect(assigns(:expense_item)).to be_a_new(ExpenseItem)
    end
  end

  describe "GET edit" do
    it "assigns the requested expense_item as @expense_item" do
      expense_item = FactoryGirl.create :expense_item
      get :edit, id: expense_item.to_param, expense_group_id: @expense_group.id
      expect(assigns(:expense_item)).to eq(expense_item)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseItem" do
        expect do
          post :create, expense_item: valid_attributes, expense_group_id: @expense_group.id
        end.to change(ExpenseItem, :count).by(1)
      end

      it "assigns a newly created expense_item as @expense_item" do
        post :create, expense_item: valid_attributes, expense_group_id: @expense_group.id
        expect(assigns(:expense_item)).to be_a(ExpenseItem)
        expect(assigns(:expense_item)).to be_persisted
      end

      it "redirects to the created expense_item" do
        post :create, expense_item: valid_attributes, expense_group_id: @expense_group.id
        expect(response).to redirect_to(expense_group_expense_items_path(@expense_group))
      end
      it "sets the maximum_per_registrant" do
        post :create, expense_group_id: @expense_group.id, expense_item: valid_attributes.merge(maximum_per_registrant: 1)
        expect(assigns(:expense_item).maximum_per_registrant).to eq(1)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved expense_item as @expense_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        post :create, expense_item: {position: 1}, expense_group_id: @expense_group.id
        expect(assigns(:expense_item)).to be_a_new(ExpenseItem)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        post :create, expense_item: {position: 1}, expense_group_id: @expense_group.id
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense_item" do
        expense_item = FactoryGirl.create :expense_item
        # Assuming there are no other expense_items in the database, this
        # specifies that the ExpenseItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(ExpenseItem).to receive(:update_attributes).with({})
        put :update, id: expense_item.to_param, expense_item: {'these' => 'params'}, expense_group_id: @expense_group.id
      end

      it "assigns the requested expense_item as @expense_item" do
        expense_item = FactoryGirl.create :expense_item
        put :update, id: expense_item.to_param, expense_item: valid_attributes, expense_group_id: @expense_group.id
        expect(assigns(:expense_item)).to eq(expense_item)
      end

      it "redirects to the expense_item" do
        expense_item = FactoryGirl.create :expense_item
        put :update, id: expense_item.to_param, expense_item: valid_attributes, expense_group_id: @expense_group.id
        expect(response).to redirect_to(expense_group_expense_items_path(@expense_group))
      end
    end

    describe "with invalid params" do
      it "assigns the expense_item as @expense_item" do
        expense_item = FactoryGirl.create :expense_item
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        put :update, id: expense_item.to_param, expense_item: {position: 1}, expense_group_id: @expense_group.id
        expect(assigns(:expense_item)).to eq(expense_item)
      end

      it "re-renders the 'edit' template" do
        expense_item = FactoryGirl.create :expense_item
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseItem).to receive(:save).and_return(false)
        put :update, id: expense_item.to_param, expense_item: {position: 1}, expense_group_id: @expense_group.id
        expect(response).to render_template("edit")
      end
    end
  end

  describe "PUT update_row_order" do
    let(:expense_group) { FactoryGirl.create(:expense_group) }
    let!(:expense_item_1) { FactoryGirl.create(:expense_item, expense_group: expense_group) }
    let!(:expense_item_2) { FactoryGirl.create(:expense_item, expense_group: expense_group) }

    it "updates the order" do
      put :update_row_order, id: expense_item_1.to_param, row_order_position: 1
      expect(expense_item_2.reload.position).to eq(1)
      expect(expense_item_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_item" do
      expense_item = FactoryGirl.create :expense_item
      expect do
        delete :destroy, id: expense_item.to_param, expense_group_id: @expense_group.id
      end.to change(ExpenseItem, :count).by(-1)
    end

    it "redirects to the expense_items list" do
      expense_item = FactoryGirl.create :expense_item, expense_group: @expense_group
      delete :destroy, id: expense_item.to_param, expense_group_id: @expense_group.id
      expect(response).to redirect_to(expense_group_expense_items_url(@expense_group))
    end
  end
end
