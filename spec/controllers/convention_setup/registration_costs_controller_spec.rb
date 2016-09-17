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
      expense_item_attributes: {
        cost: @comp_exp.cost,
        tax: @comp_exp.tax
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
    it "assigns all registration_costs as @registration_costs" do
      registration_cost
      get :index, {}
      expect(assigns(:registration_costs)).to eq([registration_cost])
    end

    it "only lists both competitor and non-competitor" do
      get :index, {}
      expect(assigns(:registrant_types)).to match_array(["competitor", "noncompetitor"])
    end

    context "in a convention without noncompetitors" do
      before { FactoryGirl.create(:event_configuration, noncompetitors: false) }

      it "only lists competitor options" do
        get :index, {}
        expect(assigns(:registrant_types)).to eq(["competitor"])
      end
    end
  end

  describe "GET new" do
    it "assigns a new registration_cost as @registration_cost" do
      get :new, {}
      expect(assigns(:registration_cost)).to be_a_new(RegistrationCost)
    end
  end

  describe "GET edit" do
    it "assigns the requested registration_cost as @registration_cost" do
      get :edit, id: registration_cost.to_param
      expect(assigns(:registration_cost)).to eq(registration_cost)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RegistrationCost" do
        expect do
          post :create, registration_cost: valid_attributes
        end.to change(RegistrationCost, :count).by(1)
      end

      it "assigns a newly created registration_cost as @registration_cost" do
        post :create, registration_cost: valid_attributes
        expect(assigns(:registration_cost)).to be_a(RegistrationCost)
        expect(assigns(:registration_cost)).to be_persisted
      end

      it "redirects to the created registration_cost" do
        post :create, registration_cost: valid_attributes
        expect(response).to redirect_to(registration_costs_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registration_cost as @registration_cost" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        post :create, registration_cost: {onsite: true}
        expect(assigns(:registration_cost)).to be_a_new(RegistrationCost)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        post :create, registration_cost: {onsite: true}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registration_cost" do
        # Assuming there are no other registration_costs in the database, this
        # specifies that the RegistrationCost created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(RegistrationCost).to receive(:update_attributes).with({})
        put :update, id: registration_cost.to_param, registration_cost: {'these' => 'params'}
      end

      it "assigns the requested registration_cost as @registration_cost" do
        put :update, id: registration_cost.to_param, registration_cost: valid_attributes
        expect(assigns(:registration_cost)).to eq(registration_cost)
      end

      it "redirects to the registration_cost" do
        params = valid_attributes.merge(expense_item_attributes: { id: registration_cost.expense_item.id })
        put :update, id: registration_cost.to_param, registration_cost: params
        expect(response).to redirect_to(registration_costs_path)
      end
    end

    describe "with invalid params" do
      it "assigns the registration_cost as @registration_cost" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        put :update, id: registration_cost.to_param, registration_cost: {name: 'fake'}
        expect(assigns(:registration_cost)).to eq(registration_cost)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrationCost).to receive(:save).and_return(false)
        put :update, id: registration_cost.to_param, registration_cost: {onsite: true}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registration_cost" do
      registration_cost
      expect do
        delete :destroy, id: registration_cost.to_param
      end.to change(RegistrationCost, :count).by(-1)
    end

    it "redirects to the registration_costs list" do
      delete :destroy, id: registration_cost.to_param
      expect(response).to redirect_to(registration_costs_url)
    end

    context "with a non-deletable expense_item (due to payment_detail)" do
      let(:expense_item) { FactoryGirl.create(:expense_item) }
      let!(:payment_detail) { FactoryGirl.create(:payment_detail, expense_item: expense_item) }
      let(:registration_cost) { FactoryGirl.create(:registration_cost, expense_item: expense_item) }

      it "cannot delete the registration_cost" do
        expect { delete :destroy, id: registration_cost.to_param }.to raise_error(ActiveRecord::DeleteRestrictionError)
        expect(RegistrationCost.find_by(id: registration_cost.id)).not_to be_nil
      end
    end
  end
end
