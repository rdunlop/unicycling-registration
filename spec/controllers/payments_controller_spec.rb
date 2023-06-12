# == Schema Information
#
# Table name: payments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  completed            :boolean          default(FALSE), not null
#  cancelled            :boolean          default(FALSE), not null
#  transaction_id       :string
#  completed_date       :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  payment_date         :string
#  note                 :string
#  invoice_id           :string
#  offline_pending      :boolean          default(FALSE), not null
#  offline_pending_date :datetime
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

require 'spec_helper'

describe PaymentsController do
  before do
    @user = FactoryBot.create(:user)
    @config = EventConfiguration.singleton
    @config.update(FactoryBot.attributes_for(:event_configuration, event_sign_up_closed_date: Date.tomorrow))
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
      completed_date: Date.new(2012, 1, 30)
    }
  end

  describe "POST fake_complete" do
    it "sets the payment as completed" do
      payment = FactoryBot.create(:payment, user: @user, transaction_id: nil)
      post :fake_complete, params: { id: payment.to_param }
      payment.reload
      expect(payment.completed).to eq(true)
    end

    it "redirects to registrants page" do
      payment = FactoryBot.create(:payment, user: @user)
      post :fake_complete, params: { id: payment.to_param }
      expect(response).to redirect_to root_path
    end

    it "cannot change if config test_mode is disabled" do
      @config.update_attribute(:test_mode, false)
      payment = FactoryBot.create(:payment, user: @user)
      post :fake_complete, params: { id: payment.to_param }
      payment.reload
      expect(payment.completed).to eq(false)
    end
  end

  describe "GET index" do
    before do
      @super_admin = FactoryBot.create(:super_admin_user)
      sign_in @super_admin
      @payment = FactoryBot.create(:payment, user: @user, completed: true)
    end

    describe "as normal user" do
      before do
        sign_in @user
      end

      it "can read index" do
        get :index, params: { user_id: @user.id }
        expect(response).to be_successful
      end

      it "receives a list of payments" do
        get :index, params: { user_id: @user.id }

        assert_select "tr>td", text: @payment.transaction_id.to_s, count: 1
      end

      it "doesn't list my payments which are not completed" do
        my_incomplete_payment = FactoryBot.create(:payment, completed: false, user: @user, note: "MY NOTE")

        get :index, params: { user_id: @user.id }

        assert_select "[contains(?)]", my_incomplete_payment.note, false
      end
    end
  end

  describe "GET index (registrants)" do
    before do
      @super_admin = FactoryBot.create(:super_admin_user)
      sign_in @super_admin
      @reg = FactoryBot.create(:competitor, user: @super_admin)
    end

    it "can get the registrants payments" do
      get :registrant_payments, params: { id: @reg }
      expect(response).to be_successful
    end

    describe "as a normal user" do
      before do
        sign_out @super_admin
        sign_in @user
      end

      it "cannot get the registrants payments" do
        get :registrant_payments, params: { id: @reg }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET show" do
    let!(:payment) { FactoryBot.create(:payment, user: @user) }
    let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment) }

    it "shows the payment form" do
      get :show, params: { id: payment.to_param }

      assert_select "form", action: payment.paypal_post_url, method: "post" do
        assert_select "input[type=hidden][name=business][value='#{@config.paypal_account}']"
        assert_select "input[type=hidden][name=cancel_return][value='#{user_payments_url(@user)}']"
        assert_select "input[type=hidden][name=cmd][value='_cart']"
        assert_select "input[type=hidden][name=currency_code][value='USD']"
        assert_select "input[type=hidden][name=invoice][value='#{payment.invoice_id}']"
        assert_select "input[type=hidden][name=no_shipping][value='1']"
        assert_select "input[type=hidden][name=notify_url][value='#{notification_payments_url(protocol: 'https')}']"
        assert_select "input[type=hidden][name=return][value='#{success_payments_url}']"
        assert_select "input[type=hidden][name=upload][value='1']"

        assert_select "input[type=submit]"
      end
    end

    context "with a payment_detail" do
      let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment) }

      it "renders the sub-entries for associated payment_details" do
        get :show, params: { id: payment.to_param }

        assert_select "form", action: payment.paypal_post_url, method: "post" do
          assert_select "input[type=hidden][name=amount_1][value='#{payment_detail.amount}']"
          assert_select "input[type=hidden][name=item_name_1][value='#{payment_detail.line_item}']"
          assert_select "input[type=hidden][name=quantity_1][value='1']"
        end
      end

      context "when the payment item costs > $1000" do
        let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment, amount_cents: 1234_56) }

        it "displays the cost without comma" do
          get :show, params: { id: payment.to_param }
          assert_select "form", action: payment.paypal_post_url, method: "post" do
            assert_select "input[type=hidden][name=amount_1][value='1234.56']"
          end
        end
      end
    end
  end

  describe "Complete a $0 payment" do
    it "sets the payment completed" do
      payment = FactoryBot.create(:payment, user: @user)
      post :complete, params: { id: payment.to_param }
      expect(payment.reload.completed).to be_truthy
    end

    it "doesn't allow completing a $1 payment" do
      request.env["HTTP_REFERER"] = root_path
      payment = FactoryBot.create(:payment, user: @user)
      FactoryBot.create(:payment_detail, payment: payment, amount: 1.00)
      post :complete, params: { id: payment.to_param }
      expect(payment.reload.completed).to be_falsy
    end
  end

  describe "GET new" do
    it "shows a new payment form" do
      get :new
      assert_select "h1", "New payment"
    end

    describe "for a user with a registrant owing money" do
      before do
        @reg_period = FactoryBot.create(:registration_cost, :competitor)
        @reg = FactoryBot.create(:competitor, user: @user)
      end

      it "assigns a new payment_detail for the registrant" do
        get :new
        assert_select "input[name='payment[payment_details_attributes][0][registrant_id]'][value=?]", @reg.id.to_s
      end

      it "sets the amount to the owing amount" do
        expect(@user.registrants.count).to eq(1)
        get :new
        assert_select "input[type=hidden][value=?]", @reg_period.expense_items.first.cost.to_s
      end

      it "associates the payment_detail with the expense_item" do
        get :new
        assert_select "input[type=hidden][value=?]", @reg_period.expense_items.first.id.to_s
      end

      it "only assigns registrants that owe money" do
        @other_reg = FactoryBot.create(:competitor, user: @user)
        @payment = FactoryBot.create(:payment)
        @pd = FactoryBot.create(:payment_detail, registrant: @other_reg, payment: @payment, amount: 100, line_item: @reg_period.expense_items.first)
        @payment.reload
        @payment.completed = true
        @payment.save
        get :new
        assert_select "input[name='payment[payment_details_attributes][0][details]']", count: 1
      end

      describe "has paid, but owes for more items" do
        before do
          @rei = FactoryBot.create(:registrant_expense_item, registrant: @reg, details: "Additional Details")
          @payment = FactoryBot.create(:payment)
          @pd = FactoryBot.create(:payment_detail, registrant: @reg, payment: @payment, amount: 100, line_item: @reg_period.expense_items.first)
          @payment.reload
          @payment.completed = true
          @payment.save
        end

        it "handles registrants who have paid, but owe more" do
          get :new
          assert_select "input[type='hidden'][value=?][name='payment[payment_details_attributes][0][line_item_id]']", @rei.line_item_id.to_s
        end

        it "copies the details" do
          get :new
          assert_select "input[type=hidden][value=?]", @rei.details
        end
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:do_action) { post :create, params: { payment: valid_attributes } }

      it "creates a new Payment" do
        expect { do_action }.to change(Payment, :count).by(1)
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
          @ei = FactoryBot.create(:expense_item)
          @reg = FactoryBot.create(:competitor)
          post :create, params: { payment: {
            payment_details_attributes: [
              {
                registrant_id: @reg.id,
                line_item_id: @ei.id,
                line_item_type: "ExpenseItem",
                details: "Additional Details",
                free: true,
                amount: 100
              }
            ]
          } }
          expect(PaymentDetail.count).to eq(1)
          expect(PaymentDetail.last.refunded?).to eq(false)
        end

        it "doesn't create an entry when it is set to _destroy" do
          @ei = FactoryBot.create(:expense_item)
          @ei2 = FactoryBot.create(:expense_item)
          @reg = FactoryBot.create(:competitor)
          post :create, params: { payment: {
            payment_details_attributes: [
              {
                registrant_id: @reg.id,
                line_item_id: @ei.id,
                line_item_type: "ExpenseItem",
                details: "Additional Details",
                free: true,
                amount: 100
              },
              {
                registrant_id: @reg.id,
                line_item_id: @ei2.id,
                line_item_type: "ExpenseItem",
                details: "Additional Details",
                free: true,
                amount: 100,
                _destroy: "1"
              }
            ]
          } }
          expect(PaymentDetail.count).to eq(1)
          expect(PaymentDetail.last.refunded?).to eq(false)
        end
      end
    end

    describe "with invalid params" do
      it "does not create a new payment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        expect do
          post :create, params: { payment: { other: true } }
        end.not_to change(Payment, :count)
      end

      it "when the params don't include payment hash" do
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        post :create
        expect(response).to redirect_to(new_payment_path)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
        post :create, params: { payment: { other: true } }
        assert_select "h1", "New payment"
      end
    end
  end

  describe "GET offline" do
    context "when EventConfiguration allows offline payment" do
      before { @config.update(offline_payment: true, offline_payment_description: "Pay here") }

      it "renders" do
        get :offline
        expect(response).to be_successful
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
    let(:payment) { FactoryBot.create(:payment) }

    context "without a valid coupon" do
      it "renders" do
        post :apply_coupon, params: { id: payment.id }
      end
    end

    context "with a valid coupon" do
    end
  end

  describe "GET summary" do
    before do
      @user.add_role :payment_admin
    end

    let!(:payment) { FactoryBot.create(:payment, completed: true) }
    let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment, amount: 5.22) }

    it "assigns the known expense groups as expense_groups" do
      item = payment_detail.line_item
      get :summary

      assert_select "a", item.expense_group.to_s
    end
  end
end
