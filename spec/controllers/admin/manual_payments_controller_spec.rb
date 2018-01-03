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
        get :choose, params: { registrant_ids: [registrant.id] }
        expect(response).to be_success
      end
    end
  end

  describe "POST payment create" do
    let(:rei) { FactoryGirl.create(:registrant_expense_item) }

    it "can create a payment with refund elements" do
      expect do
        post :create, params: { manual_payment: {
          unpaid_details_attributes: {
            "0" => {
              registrant_expense_item_id: rei.id,
              pay_for: "1"
            }
          }
        } }
      end.to change(Payment, :count).by(1)
      p = Payment.last
      expect(p.completed).to be_falsey
      pd = PaymentDetail.last
      expect(pd.line_item).to eq(rei.line_item)
    end

    context "with invalid params" do
      it "redirects to new_manual_payment_path" do
        post :create
        expect(response).to redirect_to(new_manual_payment_path)
      end
    end
  end
end
