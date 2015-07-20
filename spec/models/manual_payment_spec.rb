require 'spec_helper'

describe ManualPayment do
  before(:each) do
    @pay = ManualPayment.new
  end

  it "requires that the note be set" do
    @pay.user = FactoryGirl.create(:payment_admin)
    expect(@pay.valid?).to eq(false)
    @pay.note = "Hello"
    expect(@pay.valid?).to eq(false)
  end

  describe "when a registrant has been added" do
    let(:registrant) { FactoryGirl.create(:competitor) }
    let(:expense_item) { FactoryGirl.create :expense_item, cost: 10.00, tax: 2.00 }
    let!(:registrant_expense_item) { FactoryGirl.create :registrant_expense_item, expense_item: expense_item, registrant: registrant }

    before :each do
      @pay.add_registrant(registrant.reload)
      @pay.unpaid_details.first.pay_for = true
    end

    it "lists the unpaid items for the registrant" do
      expect(@pay.unpaid_details.size).to eq(1)
    end

    it "is valid with a note" do
      expect(@pay).not_to be_valid
      @pay.note = "Paid by cheque"
      expect(@pay).to be_valid
    end

    describe "with a built payment" do
      let(:payment) { @pay.build_payment }

      it "sets the payment_detail to the total cost" do
        expect(payment.payment_details.first.amount).to eq 12.00
      end
    end
  end
end
