require 'spec_helper'

describe ExpenseGroupsController do
  before(:each) do
    @admin = FactoryGirl.create(:admin_user)
    sign_in @admin
  end

  # This should return the minimal set of attributes required to create a valid
  # ExpenseGroup. As you add validations to ExpenseGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      group_name: "T-Shirts",
      visible: true
    }
  end

  describe "GET index" do
    it "assigns all expense_groups as @expense_groups" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :index, {}
      assigns(:expense_groups).should eq([expense_group])
      assigns(:expense_group).should be_a_new(ExpenseGroup)
    end
  end

  describe "GET show" do
    it "assigns the requested expense_group as @expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :show, {:id => expense_group.to_param}
      assigns(:expense_group).should eq(expense_group)
    end
  end

  describe "GET edit" do
    it "assigns the requested expense_group as @expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :edit, {:id => expense_group.to_param}
      assigns(:expense_group).should eq(expense_group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseGroup" do
        expect {
          post :create, {:expense_group => valid_attributes}
        }.to change(ExpenseGroup, :count).by(1)
      end

      it "assigns a newly created expense_group as @expense_group" do
        post :create, {:expense_group => valid_attributes}
        assigns(:expense_group).should be_a(ExpenseGroup)
        assigns(:expense_group).should be_persisted
      end

      it "redirects to the created expense_group" do
        post :create, {:expense_group => valid_attributes}
        response.should redirect_to(ExpenseGroup.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved expense_group as @expense_group" do
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseGroup.any_instance.stub(:save).and_return(false)
        post :create, {:expense_group => {}}
        assigns(:expense_group).should be_a_new(ExpenseGroup)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseGroup.any_instance.stub(:save).and_return(false)
        post :create, {:expense_group => {}}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Assuming there are no other expense_groups in the database, this
        # specifies that the ExpenseGroup created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ExpenseGroup.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => expense_group.to_param, :expense_group => {'these' => 'params'}}
      end

      it "assigns the requested expense_group as @expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        put :update, {:id => expense_group.to_param, :expense_group => valid_attributes}
        assigns(:expense_group).should eq(expense_group)
      end

      it "redirects to the expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        put :update, {:id => expense_group.to_param, :expense_group => valid_attributes}
        response.should redirect_to(expense_group)
      end
    end

    describe "with invalid params" do
      it "assigns the expense_group as @expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseGroup.any_instance.stub(:save).and_return(false)
        put :update, {:id => expense_group.to_param, :expense_group => {}}
        assigns(:expense_group).should eq(expense_group)
      end

      it "re-renders the 'edit' template" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ExpenseGroup.any_instance.stub(:save).and_return(false)
        put :update, {:id => expense_group.to_param, :expense_group => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      expect {
        delete :destroy, {:id => expense_group.to_param}
      }.to change(ExpenseGroup, :count).by(-1)
    end

    it "redirects to the expense_groups list" do
      expense_group = ExpenseGroup.create! valid_attributes
      delete :destroy, {:id => expense_group.to_param}
      response.should redirect_to(expense_groups_url)
    end
  end

end
