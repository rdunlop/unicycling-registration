require 'spec_helper'

describe PaymentAdjustmentsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, completed: true, transaction_id: "My Transaction ID") }
  let!(:other_payment) { FactoryGirl.create(:payment, transaction_id: "Other Transaction ID") }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, amount: 5.22) }

  describe "GET list" do
    it "lists all payments" do
      get :list

      assert_select "h1", "Listing payments And Refunds"
      assert_select "td", payment.transaction_id
      assert_select "td", other_payment.transaction_id
    end
  end

  describe "GET new" do
    it "Renders" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST adjust_payment_choose" do
    let(:registrant) { FactoryGirl.create(:registrant) }

    context "without choosing a registrant" do
      it "redirects to :new" do
        post :adjust_payment_choose
        expect(response).to redirect_to(new_payment_adjustment_path)
      end
    end

    context "with a registrant" do
      it "renders" do
        post :adjust_payment_choose, params: { registrant_id: [registrant.id] }
      end
    end
  end

  describe "POST exchange_choose" do
  end

  describe "POST exchange_create" do
    let(:registrant) { payment_detail.registrant.reload }
    let(:new_expense_item) { FactoryGirl.create(:expense_item) }
    let(:other_expense_item) { FactoryGirl.create(:expense_item) }

    it "can create an exchange of elements" do
      expect do
        post :exchange_create, params: { note: "exchange shirts",
                                         registrant_id: registrant.id,
                                         old_item_id: payment_detail.expense_item.id,
                                         new_item_id: new_expense_item.id }
      end.to change(RefundDetail, :count).by(1)
      r = Refund.last
      expect(r.note).to eq("exchange shirts")
      expect(r.refund_details.first.payment_detail).to eq(payment_detail)

      p = Payment.last
      expect(p.completed).to eq(true)
      expect(p.note).to eq("exchange shirts")
      expect(p.payment_details.first.expense_item).to eq(new_expense_item)
    end

    it "doesn't create any refunds when there is not a matching paid expense item" do
      expect do
        post :exchange_create, params: { note: "exchange shirts",
                                         registrant_id: registrant.id,
                                         old_item_id: other_expense_item.id,
                                         new_item_id: new_expense_item.id }
      end.to_not change(Refund, :count)
    end
  end
end
