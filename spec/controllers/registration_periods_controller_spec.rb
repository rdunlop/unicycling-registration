require 'spec_helper'

describe RegistrationPeriodsController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
    @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
    @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
  end

  # This should return the minimal set of attributes required to create a valid
  # RegistrationPeriod. As you add validations to RegistrationPeriod, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      start_date: Date.new(2013, 01, 20),
      end_date: Date.new(2013, 02, 20),
      onsite: false,
      name: "Early",
      competitor_expense_item_attributes: {
        cost: @comp_exp.cost,
        tax_percentage: @comp_exp.tax_percentage
      },
      noncompetitor_expense_item_attributes: {
        cost: @noncomp_exp.cost,
        tax_percentage: @noncomp_exp.tax_percentage,
      }
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read registration_periods" do
      get :index
      response.should redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all registration_periods as @registration_periods" do
      registration_period = FactoryGirl.create :registration_period
      get :index, {}
      assigns(:registration_periods).should eq([registration_period])
    end
  end

  describe "GET show" do
    it "assigns the requested registration_period as @registration_period" do
      registration_period = FactoryGirl.create :registration_period
      get :show, {:id => registration_period.to_param}
      assigns(:registration_period).should eq(registration_period)
    end
  end

  describe "GET new" do
    it "assigns a new registration_period as @registration_period" do
      get :new, {}
      assigns(:registration_period).should be_a_new(RegistrationPeriod)
    end
  end

  describe "GET edit" do
    it "assigns the requested registration_period as @registration_period" do
      registration_period = FactoryGirl.create :registration_period
      get :edit, {:id => registration_period.to_param}
      assigns(:registration_period).should eq(registration_period)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RegistrationPeriod" do
        expect {
          post :create, {:registration_period => valid_attributes}
        }.to change(RegistrationPeriod, :count).by(1)
      end

      it "assigns a newly created registration_period as @registration_period" do
        post :create, {:registration_period => valid_attributes}
        assigns(:registration_period).should be_a(RegistrationPeriod)
        assigns(:registration_period).should be_persisted
      end

      it "redirects to the created registration_period" do
        post :create, {:registration_period => valid_attributes}
        response.should redirect_to(RegistrationPeriod.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registration_period as @registration_period" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrationPeriod.any_instance.stub(:save).and_return(false)
        post :create, {:registration_period => {:onsite => true}}
        assigns(:registration_period).should be_a_new(RegistrationPeriod)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrationPeriod.any_instance.stub(:save).and_return(false)
        post :create, {:registration_period => {:onsite => true}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registration_period" do
        registration_period = FactoryGirl.create :registration_period
        # Assuming there are no other registration_periods in the database, this
        # specifies that the RegistrationPeriod created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        RegistrationPeriod.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => registration_period.to_param, :registration_period => {'these' => 'params'}}
      end

      it "assigns the requested registration_period as @registration_period" do
        registration_period = FactoryGirl.create :registration_period
        put :update, {:id => registration_period.to_param, :registration_period => valid_attributes}
        assigns(:registration_period).should eq(registration_period)
      end

      it "redirects to the registration_period" do
        registration_period = FactoryGirl.create :registration_period
        params = valid_attributes.merge({
          competitor_expense_item_attributes: { id: registration_period.competitor_expense_item.id },
          noncompetitor_expense_item_attributes: { id: registration_period.noncompetitor_expense_item.id },
          })
        put :update, {:id => registration_period.to_param, :registration_period => params}
        response.should redirect_to(registration_period)
      end
    end

    describe "with invalid params" do
      it "assigns the registration_period as @registration_period" do
        registration_period = FactoryGirl.create :registration_period
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrationPeriod.any_instance.stub(:save).and_return(false)
        put :update, {:id => registration_period.to_param, :registration_period => {:name => 'fake'}}
        assigns(:registration_period).should eq(registration_period)
      end

      it "re-renders the 'edit' template" do
        registration_period = FactoryGirl.create :registration_period
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrationPeriod.any_instance.stub(:save).and_return(false)
        put :update, {:id => registration_period.to_param, :registration_period => {:onsite => true}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registration_period" do
      registration_period = FactoryGirl.create :registration_period
      expect {
        delete :destroy, {:id => registration_period.to_param}
      }.to change(RegistrationPeriod, :count).by(-1)
    end

    it "redirects to the registration_periods list" do
      registration_period = FactoryGirl.create :registration_period
      delete :destroy, {:id => registration_period.to_param}
      response.should redirect_to(registration_periods_url)
    end
  end

end
