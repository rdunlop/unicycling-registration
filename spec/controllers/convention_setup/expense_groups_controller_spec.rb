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
    it "assigns all expense_groups as @expense_groups" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :index, {}
      expect(assigns(:expense_groups)).to eq([expense_group])
      expect(assigns(:expense_group)).to be_a_new(ExpenseGroup)
    end
  end

  describe "GET edit" do
    it "assigns the requested expense_group as @expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      get :edit, {id: expense_group.to_param}
      expect(assigns(:expense_group)).to eq(expense_group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ExpenseGroup" do
        expect do
          post :create, {expense_group: valid_attributes}
        end.to change(ExpenseGroup, :count).by(1)
      end

      it "assigns a newly created expense_group as @expense_group" do
        post :create, {expense_group: valid_attributes}
        expect(assigns(:expense_group)).to be_a(ExpenseGroup)
        expect(assigns(:expense_group)).to be_persisted
        expect(assigns(:expense_group).group_name).to eq("group_en")
      end

      it "redirects to the created expense_group" do
        post :create, {expense_group: valid_attributes}
        expect(response).to redirect_to(expense_groups_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved expense_group as @expense_group" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        post :create, {expense_group: {info_url: "hi"}}
        expect(assigns(:expense_group)).to be_a_new(ExpenseGroup)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        post :create, {expense_group: {info_url: "hi"}}
        expect(response).to render_template("index")
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
        expect_any_instance_of(ExpenseGroup).to receive(:update_attributes).with({})
        put :update, {id: expense_group.to_param, expense_group: {'these' => 'params'}}
      end

      it "assigns the requested expense_group as @expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        put :update, {id: expense_group.to_param, expense_group: valid_attributes}
        expect(assigns(:expense_group)).to eq(expense_group)
      end

      it "redirects to the expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        put :update, {id: expense_group.to_param, expense_group: valid_attributes}
        expect(response).to redirect_to(expense_groups_path)
      end
    end

    describe "with invalid params" do
      it "assigns the expense_group as @expense_group" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        put :update, {id: expense_group.to_param, expense_group: {info_url: "fake"}}
        expect(assigns(:expense_group)).to eq(expense_group)
      end

      it "re-renders the 'edit' template" do
        expense_group = ExpenseGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ExpenseGroup).to receive(:save).and_return(false)
        put :update, {id: expense_group.to_param, expense_group: {info_url: "hi"}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense_group" do
      expense_group = ExpenseGroup.create! valid_attributes
      expect do
        delete :destroy, {id: expense_group.to_param}
      end.to change(ExpenseGroup, :count).by(-1)
    end

    it "redirects to the expense_groups list" do
      expense_group = ExpenseGroup.create! valid_attributes
      delete :destroy, {id: expense_group.to_param}
      expect(response).to redirect_to(expense_groups_url)
    end
  end
end
