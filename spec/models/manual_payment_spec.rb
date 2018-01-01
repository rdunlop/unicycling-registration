require 'spec_helper'

describe ManualPayment do
  before(:each) do
    @pay = ManualPayment.new
  end

  describe "when a registrant has been added" do
    let(:registrant) { FactoryGirl.create(:competitor) }
    let(:expense_item) { FactoryGirl.create :expense_item, cost: 10.00, tax: 2.00 }
    let!(:registrant_expense_item) { FactoryGirl.create :registrant_expense_item, line_item: expense_item, registrant: registrant }

    before :each do
      @pay.add_registrant(registrant.reload)
      @pay.unpaid_details.first.pay_for = true
    end

    it "lists the unpaid items for the registrant" do
      expect(@pay.unpaid_details.size).to eq(1)
    end

    describe "with a built payment" do
      let(:payment) { @pay.build_payment }

      it "sets the payment_detail to the total cost" do
        expect(payment.payment_details.first.amount).to eq 12.00.to_money
      end
    end
  end
end
