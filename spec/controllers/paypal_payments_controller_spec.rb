require 'spec_helper'

describe PaypalPaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @config = EventConfiguration.singleton
    @config.update(FactoryGirl.attributes_for(:event_configuration))
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

  describe "without a user signed in" do
    before(:each) do
      sign_out @user
    end
    let(:paypal_account) { @config.paypal_account.downcase }

    describe "with a valid IPN for a valid payment" do
      before(:each) do
        @payment = FactoryGirl.create(:payment, transaction_id: nil, completed_date: nil)
        @payment_detail = FactoryGirl.create(:payment_detail, payment: @payment, amount: 20.00)
        @payment.reload
      end

      it "is OK even when incomplete" do
        post :notification, params: { payment_status: "Incomplete" }
        expect(response).to be_success
      end

      describe "with a valid post" do
        let(:attributes) do
          {
            receiver_email: paypal_account,
            payment_status: "Completed",
            txn_id: "12345",
            payment_date: "Some Paypal payment date",
            invoice: @payment.invoice_id,
            mc_gross: @payment.total_amount
          }
        end

        it "sets the payment as completed" do
          post :notification, params: attributes
          expect(response).to be_success
          @payment.reload
          expect(@payment.completed).to eq(true)
        end
        it "sets the transaction number" do
          post :notification, params: attributes
          expect(response).to be_success
          @payment.reload
          expect(@payment.transaction_id).to eq("12345")
        end
        it "sets the completed_date to today" do
          travel_to Time.current do # freeze time
            t = Time.current
            post :notification, params: attributes
            expect(response).to be_success
            @payment.reload
            expect(@payment.completed_date.to_i).to eq(t.to_i)
          end
        end
        it "sets the payment_date to the received payment_date string" do
          post :notification, params: attributes
          expect(response).to be_success
          @payment.reload
          expect(@payment.payment_date).to eq("Some Paypal payment date")
        end
      end
      describe "with an incorrect payment_id" do
        let(:attributes) do
          {
            receiver_email: paypal_account,
            payment_status: "Completed",
            txn_id: "12345",
            invoice: "WRONG_INVOICE_NUMBER",
            mc_gross: @payment.total_amount
          }
        end
        it "sends an IPN message" do
          ActionMailer::Base.deliveries.clear
          post :notification, params: attributes
          expect(response).to be_success
          num_deliveries = ActionMailer::Base.deliveries.size
          expect(num_deliveries).to eq(1) # one for error
        end
      end
      it "doesn't set the payment if the wrong paypal account is specified" do
        post :notification, params: { receiver_email: "bob@bob.com", payment_status: "Completed", invoice: @payment.invoice_id }
        expect(response).to be_success
        @payment.reload
        expect(@payment.completed).to eq(false)
      end
      it "should send an e-mail to notify of payment receipt" do
        ActionMailer::Base.deliveries.clear
        post :notification, params: { mc_gross: "20.00", receiver_email: paypal_account, payment_status: "Completed", invoice: @payment.invoice_id }
        expect(response).to be_success
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1) # one for success
      end
      it "should send an e-mail to notify of payment error when mc_gross is empty" do
        ActionMailer::Base.deliveries.clear
        post :notification, params: { mc_gross: "", receiver_email: paypal_account, payment_status: "Completed", invoice: @payment.invoice_id }
        expect(response).to be_success
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(2) # one for success, one for the error
      end

      it "should send an IPN notification message if the total amount doesn't match the payment total" do
        ActionMailer::Base.deliveries.clear
        post :notification, params: { mc_gross: @payment.total_amount - 1.to_money, receiver_email: paypal_account, payment_status: "Completed", invoice: @payment.invoice_id }
        expect(response).to be_success
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(2) # one for success, one for the error (payment different)
      end
    end

    describe "when directed to the payment_success page" do
      it "can get there without being logged in" do
        get :success
        expect(response).to be_success
      end
    end
  end
end
