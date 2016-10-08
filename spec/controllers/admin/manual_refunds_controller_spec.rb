require 'spec_helper'

describe Admin::ManualRefundsController do
  before(:each) do
    @user = FactoryGirl.create(:payment_admin)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, completed: true) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, amount: 5.22) }

  let(:registrant) { FactoryGirl.create(:registrant) }

  describe "GET new" do
    it "renders" do
      get :new
      expect(response).to be_success
    end
  end

  describe "GET choose" do
    context "without any registrant_ids" do
      it "redirects" do
        get :choose
        expect(response).to redirect_to(action: :new)
      end
    end

    context "with registrant_ids" do
      it "renders" do
        get :choose, params: { registrant_ids: [registrant.id] }
        expect(response).to be_success
      end
    end
  end

  describe "POST refund create" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail)
    end

    it "can create a payment with refund elements" do
      expect do
        post :create, params: { manual_refund: {
          note: "Cancelled",
          percentage: 100,
          items_attributes: {
            "0" => {
              paid_detail_id: @pd.id,
              refund: true
            }}
        } }
      end.to change(RefundDetail, :count).by(1)
      r = Refund.last
      expect(r.note).to eq("Cancelled")
      rd = RefundDetail.last
      expect(rd.payment_detail).to eq(@pd)
    end
  end
end
