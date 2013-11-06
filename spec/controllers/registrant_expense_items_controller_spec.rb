require 'spec_helper'

describe RegistrantExpenseItemsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @reg = FactoryGirl.create(:registrant, :user => @user)
    @exp = FactoryGirl.create(:expense_item)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # RegistrantGroup. As you add validations to RegistrantGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :free => false,
      :details => nil,
      :expense_item_id => @exp.id
    }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RegistrantExpenseItem" do
        expect {
          post :create, {:registrant_expense_item => valid_attributes, :registrant_id => @reg.id}
        }.to change(RegistrantExpenseItem, :count).by(1)
      end

      it "assigns a newly created registrant_expense_item as @registrant_expense_item" do
        post :create, {:registrant_expense_item => valid_attributes, :registrant_id => @reg.id}
        assigns(:registrant_expense_item).should be_a(RegistrantExpenseItem)
        assigns(:registrant_expense_item).should be_persisted
      end

      it "redirects to the created item_registrants_path" do
        post :create, {:registrant_expense_item => valid_attributes, :registrant_id => @reg.id}
        response.should redirect_to(items_registrant_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant_expense_item as @registrant_expense_Item" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantExpenseItem.any_instance.stub(:save).and_return(false)
        post :create, {:registrant_expense_item => { "details" => "invalid value" }, :registrant_id => @reg.id}
        assigns(:registrant_expense_item).should be_a_new(RegistrantExpenseItem)
      end

      it "re-renders the 'items' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantExpenseItem.any_instance.stub(:save).and_return(false)
        post :create, {:registrant_expense_item => { "details" => "invalid value" }, :registrant_id => @reg.id}
        response.should render_template("items")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registrant_expense_item" do
      registrant_expense_item = FactoryGirl.create(:registrant_expense_item, :registrant => @reg)
      expect {
        delete :destroy, {:id => registrant_expense_item.to_param, :registrant_id => @reg.id}
      }.to change(RegistrantExpenseItem, :count).by(-1)
    end

    it "redirects to the registrant_items list" do
      registrant_expense_item = FactoryGirl.create(:registrant_expense_item, :registrant => @reg)
      reg = registrant_expense_item.registrant
      delete :destroy, {:id => registrant_expense_item.to_param, :registrant_id => @reg.id}
      response.should redirect_to(items_registrant_path(reg))
    end
  end

end
