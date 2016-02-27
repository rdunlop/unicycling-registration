require 'spec_helper'

describe Admin::ManualPaymentsController do
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
        get :choose, registrant_ids: [registrant.id]
        expect(response).to be_success
      end
    end
  end

  describe "POST payment create" do
    let(:rei) { FactoryGirl.create(:registrant_expense_item) }

    it "can create a payment with refund elements" do
      expect do
        post :create, manual_payment: {
          note: "Paid manually",
          unpaid_details_attributes: {
            "0" => {
              registrant_expense_item_id: rei.id,
              pay_for: "1"
            }}
        }
      end.to change(Payment, :count).by(1)
      p = Payment.last
      expect(p.note).to eq("Paid manually")
      pd = PaymentDetail.last
      expect(pd.expense_item).to eq(rei.expense_item)
    end
  end
end
