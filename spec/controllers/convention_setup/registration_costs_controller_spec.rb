require 'spec_helper'

describe ConventionSetup::RegistrationCostsController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
    @comp_exp = FactoryGirl.create(:expense_item, cost: 100)
  end

  let(:registration_cost) { FactoryGirl.create(:registration_cost) }

  # This should return the minimal set of attributes required to create a valid
  # RegistrationCost. As you add validations to RegistrationCost, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      start_date: Date.new(2013, 1, 20),
      end_date: Date.new(2013, 2, 20),
      onsite: false,
      name: "Early Competitor",
      registrant_type: "competitor",
      registration_cost_entries_attributes: {
        "1" => {
          expense_item_attributes: {
            cost: @comp_exp.cost,
            tax: @comp_exp.tax
          }
        }

      }
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read registration_costs" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all registration_costs" do
      registration_cost
      get :index

      assert_select "h1", "Registration Costs"
      assert_select "td", registration_cost.name
    end
  end

  describe "GET new" do
    it "shows a new registration_cost" do
      get :new
      assert_select "h1", "New Registration Cost Entry"
    end

    it "only lists both competitor and non-competitor" do
      get :new

      assert_select "form.new_registration_cost" do
        assert_select "select#registration_cost_registrant_type", name: "registration_cost[registrant_type]" do
          assert_select "option", value: "competitor"
          assert_select "option", value: "noncompetitor"
        end
      end
    end

    context "in a convention without noncompetitors" do
      before { EventConfiguration.singleton.update(noncompetitors: false) }

      it "only lists competitor options" do
        get :new
        assert_select "select#registration_cost_registrant_type", name: "registration_cost[registrant_type]" do
          assert_select "option", value: "competitor"
          assert_select "option", 2 # blank and competitor, no "Noncompetitor" option
        end
      end
    end
  end

  describe "GET edit" do
    it "shows the requested registration_cost form" do
      get :edit, params: { id: registration_cost.to_param }

      assert_select "h1", "Editing #{registration_cost} Registration Cost"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RegistrationCost" do
        expect do
          post :create, params: { registration_cost: valid_attributes }
        end.to change(RegistrationCost, :count).by(1)
      end

      it "redirects to the created registration_cost" do
        post :create, params: { registration_cost: valid_attributes }
        expect(response).to redirect_to(registration_costs_path)
      end
    end

    describe "with min and max ages" do
      it "creates new registration_cost_entry" do
        params =  valid_attributes.deep_merge(
          registration_cost_entries_attributes: {
            "1" => {
              min_age: 10,
              max_age: 50
            }
          })
        post :create, params: { registration_cost: params }
        rce = RegistrationCostEntry.first
        expect(rce.min_age).to eq(10)
        expect(rce.max_age).to eq(50)
      end
    end

    describe "with invalid params" do
      it "does not create a new registration_cost" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        expect do
          post :create, params: { registration_cost: {onsite: true} }
        end.not_to change(RegistrationCost, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        post :create, params: { registration_cost: {onsite: true} }
        assert_select "h1", "New Registration Cost Entry"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the registration_cost" do
        expect do
          put :update, params: { id: registration_cost.to_param, registration_cost: {name: "New Namee"} }
        end.to change { registration_cost.reload.name }
      end

      it "redirects to the registration_cost" do
        params = valid_attributes.deep_merge(
          registration_cost_entries_attributes: {
            "1" => {
              expense_item_attributes: {
                id: registration_cost.expense_items.first.id
              },
              id: registration_cost.registration_cost_entries.first.id
            }
          })
        put :update, params: { id: registration_cost.to_param, registration_cost: params }
        expect(response).to redirect_to(registration_costs_path)
      end
    end

    describe "with invalid params" do
      it "does not update the registration_cost" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: registration_cost.to_param, registration_cost: {name: 'fake'} }
        end.not_to change { registration_cost.reload.name }
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        put :update, params: { id: registration_cost.to_param, registration_cost: {onsite: true} }
        assert_select "h1", "Editing #{registration_cost} Registration Cost"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registration_cost" do
      registration_cost
      expect do
        delete :destroy, params: { id: registration_cost.to_param }
      end.to change(RegistrationCost, :count).by(-1)
    end

    it "redirects to the registration_costs list" do
      delete :destroy, params: { id: registration_cost.to_param }
      expect(response).to redirect_to(registration_costs_url)
    end

    context "with a non-deletable expense_item (due to payment_detail)" do
      let(:expense_item) { FactoryGirl.create(:expense_item) }
      let!(:payment_detail) { FactoryGirl.create(:payment_detail, expense_item: expense_item) }
      let(:registration_cost) { FactoryGirl.create(:registration_cost, expense_item: expense_item) }

      it "cannot delete the registration_cost" do
        expect { delete :destroy, params: { id: registration_cost.to_param } }.to raise_error(ActiveRecord::DeleteRestrictionError)
        expect(RegistrationCost.find_by(id: registration_cost.id)).not_to be_nil
      end
    end
  end
end
