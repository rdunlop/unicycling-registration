require 'spec_helper'

describe ExpenseItemsController do
  before(:each) do
    @admin = FactoryGirl.create(:admin_user)
    sign_in @admin

    @expense_group = FactoryGirl.create(:expense_group)
  end

  # This should return the minimal set of attributes required to create a valid
  # ExpenseItem. As you add validations to ExpenseItem, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :name => "Small T-Shirt",
      :description => "Small NAUCC T-Shirt",
      :cost => 15.00,
      :expense_group_id => @expense_group.id,
      :position => 1
    }
  end

  describe "GET index" do
    it "assigns all expense_items as @expense_items" do
      expense_item = ExpenseItem.create! valid_attributes
      get :index, {}
      assigns(:expense_items).should eq([expense_item])
      assigns(:expense_item).should be_a_new(ExpenseItem)
    end
  end

  describe "GET edit" do
    it "assigns the requested expense_item as @expense_item" do
      expense_item = ExpenseItem.create! valid_attributes
      get :edit, {:id => expense_item.to_param}
      assigns(:expense_item).should eq(expense_item)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseItem" do
        expect {
          post :create, {:expense_item => valid_attributes}
        }.to change(ExpenseItem, :count).by(1)
      end

      it "assigns a newly created expense_item as @expense_item" do
        post :create, {:expense_item => valid_attributes}
        assigns(:expense_item).should be_a(ExpenseItem)
        assigns(:expense_item).should be_persisted
      end

      it "redirects to the created expense_item" do
        post :create, {:expense_item => valid_attributes}
        response.should redirect_to(expense_items_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved expense_item as @expense_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseItem.any_instance.stub(:save).and_return(false)
        post :create, {:expense_item => {}}
        assigns(:expense_item).should be_a_new(ExpenseItem)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseItem.any_instance.stub(:save).and_return(false)
        post :create, {:expense_item => {}}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense_item" do
        expense_item = ExpenseItem.create! valid_attributes
        # Assuming there are no other expense_items in the database, this
        # specifies that the ExpenseItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ExpenseItem.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => expense_item.to_param, :expense_item => {'these' => 'params'}}
      end

      it "assigns the requested expense_item as @expense_item" do
        expense_item = ExpenseItem.create! valid_attributes
        put :update, {:id => expense_item.to_param, :expense_item => valid_attributes}
        assigns(:expense_item).should eq(expense_item)
      end

      it "redirects to the expense_item" do
        expense_item = ExpenseItem.create! valid_attributes
        put :update, {:id => expense_item.to_param, :expense_item => valid_attributes}
        response.should redirect_to(expense_items_path)
      end
    end

    describe "with invalid params" do
      it "assigns the expense_item as @expense_item" do
        expense_item = ExpenseItem.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseItem.any_instance.stub(:save).and_return(false)
        put :update, {:id => expense_item.to_param, :expense_item => {}}
        assigns(:expense_item).should eq(expense_item)
      end

      it "re-renders the 'edit' template" do
        expense_item = ExpenseItem.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseItem.any_instance.stub(:save).and_return(false)
        put :update, {:id => expense_item.to_param, :expense_item => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_item" do
      expense_item = ExpenseItem.create! valid_attributes
      expect {
        delete :destroy, {:id => expense_item.to_param}
      }.to change(ExpenseItem, :count).by(-1)
    end

    it "redirects to the expense_items list" do
      expense_item = ExpenseItem.create! valid_attributes
      delete :destroy, {:id => expense_item.to_param}
      response.should redirect_to(expense_items_url)
    end
  end

end
