require 'spec_helper'

describe Admin::PendingPaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:payment_admin)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, transaction_id: nil, note: "a note") }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, amount: 5.22) }

  describe "POST pay" do
    it "renders" do
      post :pay, params: { id: payment.id, payment: { note: "paid manually" } }
      expect(response).to redirect_to(payment_path(payment))
    end

    context "with invalid params" do
      it "redirects to new_manual_payment_path" do
        post :pay, params: { id: payment.id, payment: { note: nil } }
        expect(response).to redirect_to(new_manual_payment_path)
      end
    end
  end
end
