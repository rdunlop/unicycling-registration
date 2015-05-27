require 'spec_helper'

describe PaymentAdjustmentsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, :completed => true) }
  let!(:other_payment) { FactoryGirl.create(:payment) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, :payment => payment, :amount => 5.22) }

  describe "GET list" do
    it "assigns all payments as @payments" do
      get :list, {}
      expect(assigns(:payments)).to match_array([payment, other_payment])
    end
  end

  describe "POST exchange_create" do
    let(:registrant) { payment_detail.registrant.reload }
    let(:new_expense_item) { FactoryGirl.create(:expense_item) }
    let(:other_expense_item) { FactoryGirl.create(:expense_item) }

    it "can create an exchange of elements" do
      expect {
        post :exchange_create, {
          note: "exchange shirts",
          registrant_id: registrant.id,
          old_item_id: payment_detail.expense_item.id,
          new_item_id: new_expense_item.id}
      }.to change(RefundDetail, :count).by(1)
      r = Refund.last
      expect(r.note).to eq("exchange shirts")
      expect(r.refund_details.first.payment_detail).to eq(payment_detail)

      p = Payment.last
      expect(p.completed).to eq(true)
      expect(p.note).to eq("exchange shirts")
      expect(p.payment_details.first.expense_item).to eq(new_expense_item)
    end

    it "doesn't create any refunds when there is not a matching paid expense item" do
      expect {
        post :exchange_create, {
          note: "exchange shirts",
          registrant_id: registrant.id,
          old_item_id: other_expense_item.id,
          new_item_id: new_expense_item.id}
      }.to_not change(Refund, :count)
    end
  end
end
