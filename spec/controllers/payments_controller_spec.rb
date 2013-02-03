require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Payment. As you add validations to Payment, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :completed => false,
      :cancelled => false,
      :transaction_id => nil,
      :completed_date => Date.new(2012, 01, 30)
    }
  end

  describe "POST fake_complete" do
    it "sets the payment as completed" do
      payment = FactoryGirl.create(:payment, :user => @user)
      post :fake_complete, {:id => payment.to_param}
      payment.reload
      payment.completed.should == true
    end
    it "redirects to registrants page" do
      payment = FactoryGirl.create(:payment, :user => @user)
      post :fake_complete, {:id => payment.to_param}
      response.should redirect_to registrants_path
    end
    it "cannot change if config test_mode is disabled" do
      FactoryGirl.create(:event_configuration, :test_mode => false)
      payment = FactoryGirl.create(:payment, :user => @user)
      post :fake_complete, {:id => payment.to_param}
      payment.reload
      payment.completed.should == false
    end
  end
  describe "GET index" do
    before(:each) do
      @super_admin = FactoryGirl.create(:super_admin_user)
      sign_in @super_admin
      @payment = FactoryGirl.create(:payment, :user => @user, :completed => true)
    end
    it "doesn't assign other people's payments as @payments" do
      get :index, {}
      assigns(:payments).should eq([])
    end
    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "can read index" do
        get :index, {}
        response.should be_success
      end
      it "receives a list of payments" do
        get :index, {}
        assigns(:payments).should eq([@payment])
      end
      it "does not include other people's payments" do
        p2 = FactoryGirl.create(:payment, :user => @super_admin)
        get :index, {}
        assigns(:payments).should eq([@payment])
      end
      it "doesn't list my payments which are not completed" do
        incomplete_payment = FactoryGirl.create(:payment, :completed => false, :user => @user)
        get :index, {}
        assigns(:payments).should eq([@payment])
      end
    end
  end

  describe "GET show" do
    it "assigns the requested payment as @payment" do
      payment = FactoryGirl.create(:payment, :user => @user)
      get :show, {:id => payment.to_param}
      assigns(:payment).should eq(payment)
    end
  end

  describe "GET new" do
    it "assigns a new payment as @payment" do
      get :new, {}
      assigns(:payment).should be_a_new(Payment)
      assigns(:payment).payment_details.should == []
    end

    describe "for a user with a registrant owing money" do
      before(:each) do
        @reg_period = FactoryGirl.create(:registration_period)
        @reg = FactoryGirl.create(:competitor, :user => @user)
      end
      it "assigns a new payment_detail for the registrant" do
        get :new, {}
        pd = assigns(:payment).payment_details.first
        pd.registrant.should == @reg
        assigns(:payment).payment_details.first.should == assigns(:payment).payment_details.last
      end
      it "sets the amount to the owing amount" do
        @user.registrants.count.should == 1
        get :new, {}
        pd = assigns(:payment).payment_details.first
        pd.amount.should == @reg_period.competitor_expense_item.cost
      end
      it "associates the payment_detail with the expense_item" do
        get :new, {}
        pd = assigns(:payment).payment_details.first
        pd.expense_item.should == @reg_period.competitor_expense_item
      end
      it "only assigns registrants that owe money" do
        @other_reg = FactoryGirl.create(:competitor, :user => @user)
        @payment = FactoryGirl.create(:payment, :completed => true)
        @pd = FactoryGirl.create(:payment_detail, :registrant => @other_reg, :payment => @payment, :amount => 100, :expense_item => @reg_period.competitor_expense_item)
        get :new, {}
        pd = assigns(:payment).payment_details.first
        pd.registrant.should == @reg
        assigns(:payment).payment_details.first.should == assigns(:payment).payment_details.last
      end
      it "handles registrants who have paid, but owe more" do
        @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg)
        @payment = FactoryGirl.create(:payment, :completed => true)
        @pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :payment => @payment, :amount => 100, :expense_item => @reg_period.competitor_expense_item)
        get :new, {}
        pd = assigns(:payment).payment_details.first
        pd.registrant.should == @reg
        assigns(:payment).payment_details.first.should == assigns(:payment).payment_details.last
        pd.expense_item.should == @rei.expense_item
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Payment" do
        expect {
          post :create, {:payment => valid_attributes}
        }.to change(Payment, :count).by(1)
      end

      it "assigns a newly created payment as @payment" do
        post :create, {:payment => valid_attributes}
        assigns(:payment).should be_a(Payment)
        assigns(:payment).should be_persisted
      end

      it "redirects to the created payment" do
        post :create, {:payment => valid_attributes}
        response.should redirect_to(Payment.last)
      end
      it" assigns the logged in user" do
        post :create, {:payment => valid_attributes}
        Payment.last.user.should == @user
      end
      describe "with nested attributes for payment_details" do
        it "creates the payment_detail" do
          @ei = FactoryGirl.create(:expense_item)
          post :create, {:payment => {
            :payment_details_attributes => [
              {
                :registrant_id => 1,
                :expense_item_id => @ei.id,
                :amount => 100
             }]
          }}
          PaymentDetail.count.should == 1
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved payment as @payment" do
        # Trigger the behavior that occurs when invalid params are submitted
        Payment.any_instance.stub(:save).and_return(false)
        post :create, {:payment => {}}
        assigns(:payment).should be_a_new(Payment)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Payment.any_instance.stub(:save).and_return(false)
        post :create, {:payment => {}}
        response.should render_template("new")
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      sign_in FactoryGirl.create(:super_admin_user)
    end
    it "destroys the requested payment" do
      payment = FactoryGirl.create(:payment, :user => @user)
      expect {
        delete :destroy, {:id => payment.to_param}
      }.to change(Payment, :count).by(-1)
    end

    it "redirects to the payments list" do
      payment = FactoryGirl.create(:payment, :user => @user)
      delete :destroy, {:id => payment.to_param}
      response.should redirect_to(payments_url)
    end
    describe "as a normal user" do
      before(:each) do
        sign_in @user
      end
      it "cannot delete" do
        payment = FactoryGirl.create(:payment, :user => @user)
        delete :destroy, {:id => payment.to_param}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "without a user signed in" do
    before(:each) do
      sign_out @user
    end

    describe "with a valid IPN for a valid payment" do
      before(:each) do
        @payment = FactoryGirl.create(:payment, :transaction_id => nil, :completed_date => nil)
        @payment_detail = FactoryGirl.create(:payment_detail, :payment => @payment, :amount => 19.99)
      end
      it "is OK even when incomplete" do
        post :notification, {:payment_status => "Incomplete"}
        response.should be_success
      end
      it "sends an e-mail for IPN receipt" do
        ActionMailer::Base.deliveries.clear
        post :notification, {:payment_status => "Incomplete"}
        num_deliveries = ActionMailer::Base.deliveries.size
        num_deliveries.should == 1
      end
      describe "with a valid post" do
        before(:each) do
          @attributes =  {
            :receiver_email => ENV["PAYPAL_ACCOUNT"].downcase, 
            :payment_status => "Completed",
            :txn_id => "12345",
            :invoice => @payment.id.to_s
          }
        end
        it "sets the payment as completed" do
          post :notification, @attributes
          response.should be_success
          @payment.reload
          @payment.completed.should == true
        end
        it "sets the transaction number" do
          post :notification, @attributes
          response.should be_success
          @payment.reload
          @payment.transaction_id.should == "12345"
        end
        it "sets the trasaction_date to today" do
          post :notification, @attributes
          response.should be_success
          @payment.reload
          @payment.completed_date.should == Date.today
        end
      end
      describe "with an incorrect payment_id" do
        before(:each) do
          @attributes =  {
            :receiver_email => ENV["PAYPAL_ACCOUNT"].downcase, 
            :payment_status => "Completed",
            :txn_id => "12345",
            :invoice => (@payment.id + 100).to_s
          }
        end
        it "sends an IPN message" do
          ActionMailer::Base.deliveries.clear
          post :notification, @attributes
          response.should be_success
          num_deliveries = ActionMailer::Base.deliveries.size
          num_deliveries.should == 2 # one for IPN, one for error
        end
      end
      it "doesn't set the payment if the wrong paypal account is specified" do
        post :notification, {:receiver_email => "bob@bob.com", :payment_status => "Completed", :invoice => @payment.id.to_s}
        response.should be_success
        @payment.reload
        @payment.completed.should == false
      end
      it "should send an e-mail to notify of payment receipt" do
        ActionMailer::Base.deliveries.clear
        post :notification, {:receiver_email => ENV["PAYPAL_ACCOUNT"].downcase, :payment_status => "Completed", :invoice => @payment.id.to_s}
        response.should be_success
        num_deliveries = ActionMailer::Base.deliveries.size
        num_deliveries.should == 2 # one for IPN, one for success
      end
    end

    describe "when directed to the payment_success page" do
      it "can get there without being logged in" do
        get :success, {}
        response.should be_success
      end
    end
  end
end
