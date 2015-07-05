require 'spec_helper'

describe Admin::ManualRefundsController do
  before(:each) do
    @user = FactoryGirl.create(:payment_admin)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, completed: true) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, amount: 5.22) }

  describe "POST refund create" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail)
    end

    it "can create a payment with refund elements" do
      expect do
        post :create, manual_refund: {
          note: "Cancelled",
          percentage: 100,
          items_attributes: {
            "0" => {
              paid_detail_id: @pd.id,
              refund: true
            }}
        }
      end.to change(RefundDetail, :count).by(1)
      r = Refund.last
      expect(r.note).to eq("Cancelled")
      rd = RefundDetail.last
      expect(rd.payment_detail).to eq(@pd)
    end
  end
end
