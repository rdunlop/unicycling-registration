# == Schema Information
#
# Table name: payments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  completed            :boolean          default(FALSE), not null
#  cancelled            :boolean          default(FALSE), not null
#  transaction_id       :string(255)
#  completed_date       :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  payment_date         :string(255)
#  note                 :string(255)
#  invoice_id           :string(255)
#  offline_pending      :boolean          default(FALSE), not null
#  offline_pending_date :datetime
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

require 'spec_helper'

describe PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @config = FactoryGirl.create(:event_configuration, event_sign_up_closed_date: Date.tomorrow)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Payment. As you add validations to Payment, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      completed: false,
      cancelled: false,
      transaction_id: nil,
      completed_date: Date.new(2012, 01, 30)
    }
  end

  describe "POST fake_complete" do
    it "sets the payment as completed" do
      payment = FactoryGirl.create(:payment, user: @user, transaction_id: nil)
      post :fake_complete, id: payment.to_param
      payment.reload
      expect(payment.completed).to eq(true)
    end
    it "redirects to registrants page" do
      payment = FactoryGirl.create(:payment, user: @user)
      post :fake_complete, id: payment.to_param
      expect(response).to redirect_to root_path
    end
    it "cannot change if config test_mode is disabled" do
      @config.update_attribute(:test_mode, false)
      payment = FactoryGirl.create(:payment, user: @user)
      post :fake_complete, id: payment.to_param
      payment.reload
      expect(payment.completed).to eq(false)
    end
  end
  describe "GET index" do
    before(:each) do
      @super_admin = FactoryGirl.create(:super_admin_user)
      sign_in @super_admin
      @payment = FactoryGirl.create(:payment, user: @user, completed: true)
    end
    it "doesn't assign other people's payments as @payments" do
      get :index, user_id: @super_admin.id
      expect(assigns(:payments)).to eq([])
    end
    describe "as normal user" do
      before(:each) do
        sign_in @user
      end
      it "can read index" do
        get :index, user_id: @user.id
        expect(response).to be_success
      end
      it "receives a list of payments" do
        get :index, user_id: @user.id
        expect(assigns(:payments)).to eq([@payment])
      end
      it "does not include other people's payments" do
        FactoryGirl.create(:payment, user: @super_admin)
        get :index, user_id: @user.id
        expect(assigns(:payments)).to eq([@payment])
      end
      it "doesn't list my payments which are not completed" do
        FactoryGirl.create(:payment, completed: false, user: @user)
        get :index, user_id: @user.id
        expect(assigns(:payments)).to eq([@payment])
      end
    end
  end

  describe "GET index (registrants)" do
    before(:each) do
      @super_admin = FactoryGirl.create(:super_admin_user)
      sign_in @super_admin
      @reg = FactoryGirl.create(:competitor, user: @super_admin)
    end

    it "can get the registrants payments" do
      get :registrant_payments, id: @reg
      expect(response).to be_success
    end

    describe "as a normal user" do
      before(:each) do
        sign_out @super_admin
        sign_in @user
      end

      it "cannot get the registrants payments" do
        get :registrant_payments, id: @reg
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET show" do
    it "assigns the requested payment as @payment" do
      payment = FactoryGirl.create(:payment, user: @user)
      get :show, id: payment.to_param
      expect(assigns(:payment)).to eq(payment)
    end
  end

  describe "Complete a $0 payment" do
    it "sets the payment completed" do
      payment = FactoryGirl.create(:payment, user: @user)
      post :complete, id: payment.to_param
      expect(payment.reload.completed).to be_truthy
    end

    it "doesn't allow completing a $1 payment" do
      request.env["HTTP_REFERER"] = root_path
      payment = FactoryGirl.create(:payment, user: @user)
      FactoryGirl.create(:payment_detail, payment: payment, amount: 1.00)
      post :complete, id: payment.to_param
      expect(payment.reload.completed).to be_falsy
    end
  end

  describe "GET new" do
    it "assigns a new payment as @payment" do
      get :new
      expect(assigns(:payment)).to be_a_new(Payment)
      expect(assigns(:payment).payment_details).to eq([])
    end

    describe "for a user with a registrant owing money" do
      before(:each) do
        @reg_period = FactoryGirl.create(:registration_cost, :competitor)
        @reg = FactoryGirl.create(:competitor, user: @user)
      end
      it "assigns a new payment_detail for the registrant" do
        get :new
        pd = assigns(:payment).payment_details.first
        expect(pd.registrant).to eq(@reg)
        expect(assigns(:payment).payment_details.first).to eq(assigns(:payment).payment_details.last)
      end
      it "sets the amount to the owing amount" do
        expect(@user.registrants.count).to eq(1)
        get :new
        pd = assigns(:payment).payment_details.first
        expect(pd.amount).to eq(@reg_period.expense_item.cost)
      end
      it "associates the payment_detail with the expense_item" do
        get :new
        pd = assigns(:payment).payment_details.first
        expect(pd.expense_item).to eq(@reg_period.expense_item)
      end
      it "only assigns registrants that owe money" do
        @other_reg = FactoryGirl.create(:competitor, user: @user)
        @payment = FactoryGirl.create(:payment)
        @pd = FactoryGirl.create(:payment_detail, registrant: @other_reg, payment: @payment, amount: 100, expense_item: @reg_period.expense_item)
        @payment.reload
        @payment.completed = true
        @payment.save
        get :new
        pd = assigns(:payment).payment_details.first
        expect(pd.registrant).to eq(@reg)
        expect(assigns(:payment).payment_details.first).to eq(assigns(:payment).payment_details.last)
      end
      describe "has paid, but owes for more items" do
        before(:each) do
          @rei = FactoryGirl.create(:registrant_expense_item, registrant: @reg, details: "Additional Details")
          @payment = FactoryGirl.create(:payment)
          @pd = FactoryGirl.create(:payment_detail, registrant: @reg, payment: @payment, amount: 100, expense_item: @reg_period.expense_item)
          @payment.reload
          @payment.completed = true
          @payment.save
        end
        it "handles registrants who have paid, but owe more" do
          get :new
          pd = assigns(:payment).payment_details.first
          expect(pd.registrant).to eq(@reg)
          expect(assigns(:payment).payment_details.first).to eq(assigns(:payment).payment_details.last)
          expect(pd.expense_item).to eq(@rei.expense_item)
        end
        it "copies the details" do
          get :new
          pd = assigns(:payment).payment_details.first
          expect(pd.details).to eq("Additional Details")
        end
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:do_action) { post :create, payment: valid_attributes }

      it "creates a new Payment" do
        expect { do_action }.to change(Payment, :count).by(1)
      end

      it "assigns a newly created payment as @payment" do
        do_action
        expect(assigns(:payment)).to be_a(Payment)
        expect(assigns(:payment)).to be_persisted
      end

      it "redirects to the created payment" do
        do_action
        expect(response).to redirect_to(Payment.last)
      end
      it "assigns the logged in user" do
        do_action
        expect(Payment.last.user).to eq(@user)
      end

      it "has an invoice_id" do
        do_action
        expect(Payment.last.invoice_id).to be_present
      end

      describe "with nested attributes for payment_details" do
        it "creates the payment_detail" do
          @ei = FactoryGirl.create(:expense_item)
          @reg = FactoryGirl.create(:competitor)
          post :create, payment: {
            payment_details_attributes: [
              {
                registrant_id: @reg.id,
                expense_item_id: @ei.id,
                details: "Additional Details",
                free: true,
                amount: 100
              }]
          }
          expect(PaymentDetail.count).to eq(1)
          expect(PaymentDetail.last.refunded?).to eq(false)
        end

        it "doesn't create an entry when it is set to _destroy" do
          @ei = FactoryGirl.create(:expense_item)
          @ei2 = FactoryGirl.create(:expense_item)
          @reg = FactoryGirl.create(:competitor)
          post :create, payment: {
            payment_details_attributes: [
              {
                registrant_id: @reg.id,
                expense_item_id: @ei.id,
                details: "Additional Details",
                free: true,
                amount: 100
              },
              {
                registrant_id: @reg.id,
                expense_item_id: @ei2.id,
                details: "Additional Details",
                free: true,
                amount: 100,
                _destroy: "1"
              }]
          }
          expect(PaymentDetail.count).to eq(1)
          expect(PaymentDetail.last.refunded?).to eq(false)
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved payment as @payment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        post :create, payment: {other: true}
        expect(assigns(:payment)).to be_a_new(Payment)
      end

      it "when the params don't include payment hash" do
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        post :create
        expect(response).to redirect_to(new_payment_path)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        post :create, payment: {other: true}
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET offline" do
    context "when EventConfiguration allows offline payment" do
      before { @config.update(offline_payment: true, offline_payment_description: "Pay here") }

      it "renders" do
        get :offline
        expect(response).to be_success
      end
    end

    context "when EventConfiguration doesn't allow offline payment" do
      it "redirects" do
        get :offline
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST apply_coupon" do
    let(:payment) { FactoryGirl.create(:payment) }

    context "without a valid coupon" do
      it "renders" do
        post :apply_coupon, id: payment.id
      end
    end

    context "with a valid coupon" do
    end
  end

  describe "GET summary" do
    before(:each) do
      @user.add_role :payment_admin
    end
    let!(:payment) { FactoryGirl.create(:payment, completed: true) }
    let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, amount: 5.22) }

    it "assigns the known expense groups as expense_groups" do
      item = payment_detail.expense_item
      get :summary
      expect(assigns(:expense_items)).to eq([item])
    end
  end
end
