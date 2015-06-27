# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  completed      :boolean          default(FALSE), not null
#  cancelled      :boolean          default(FALSE), not null
#  transaction_id :string(255)
#  completed_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  payment_date   :string(255)
#  note           :string(255)
#  invoice_id     :string(255)
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

require 'spec_helper'
require 'cgi'

describe Payment do
  before(:each) do
    @pay = FactoryGirl.create(:payment)
  end

  it "can be created by FactoryGirl" do
    expect(@pay.valid?).to eq(true)
  end

  it "defaults completed to false" do
    p = Payment.new
    expect(p.completed).to eq(false)
  end

  it "defaults cancelled to false" do
    p = Payment.new
    expect(p.cancelled).to eq(false)
  end

  it "Requires user" do
    @pay.user = nil
    expect(@pay.valid?).to eq(false)
  end

  describe "with payment details" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail, payment: @pay, amount: 57.49)
      @pay.reload
    end

    it "has payment_details" do
      expect(@pay.payment_details).to eq([@pd])
    end
    it "can calcalate the payment total-amount" do
      @pd2 = FactoryGirl.create(:payment_detail, payment: @pay, amount: 23.0)
      expect(@pay.total_amount == "80.49".to_f).to eq(true)
    end

    it "has a list of unique_payment_deatils" do
      expect(@pay.unique_payment_details).to eq([PaymentDetailSummary.new(expense_item_id: @pd.expense_item_id, count: 1, amount: @pd.amount)])
    end

    describe "with mulitple payment_details of the same expense_item" do
      before(:each) do
        @pd2 = FactoryGirl.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details, expense_item: @pd.expense_item)
        @pd3 = FactoryGirl.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details, expense_item: @pd.expense_item)
      end

      it "only lists the element once" do
        expect(@pay.unique_payment_details.count).to eq(1)
        expect(@pay.unique_payment_details).to eq([PaymentDetailSummary.new(expense_item_id: @pd.expense_item_id, count: 3, amount: @pd.amount)])
      end

      describe "with payment_details of different expense_items" do
        before(:each) do
          @pdb = FactoryGirl.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details)
        end

        it "lists the entries separately" do
          expect(@pay.unique_payment_details.count).to eq(2)
        end
      end

      describe "with different amounts" do
        before(:each) do
          @pdc = FactoryGirl.create(:payment_detail, payment: @pd.payment, amount: 99.98, details: @pd.details, expense_item: @pd.expense_item)
        end

        it "does not group them together" do
          expect(@pay.unique_payment_details.count).to eq(2)
          expect(@pay.unique_payment_details).to match_array([PaymentDetailSummary.new(expense_item_id: @pd.expense_item_id, count: 1, amount: @pdc.amount),
                                                              PaymentDetailSummary.new(expense_item_id: @pd.expense_item_id, count: 3, amount: @pd2.amount)])
        end
      end
    end
  end

  describe "With an environment config with test mode disabled" do
    let!(:event_configuration) { FactoryGirl.create :event_configuration, paypal_mode: "enabled" }

    it "has a REAL paypal_post_url" do
      expect(@pay.paypal_post_url).to eq("https://www.paypal.com/cgi-bin/webscr")
    end
  end

  it "saves associated details when the payment is saved" do
    pay = FactoryGirl.build(:payment)
    pd = pay.payment_details.build()
    pd.registrant = FactoryGirl.create(:registrant)
    pd.amount = 100
    pd.expense_item = FactoryGirl.create(:expense_item)
    expect(PaymentDetail.all.count).to eq(0)
    pay.save
    expect(PaymentDetail.all.count).to eq(1)
  end

  it "destroys related payment_details upon destroy" do
    pay = FactoryGirl.create(:payment)
    FactoryGirl.create(:payment_detail, payment: pay)
    pay.reload
    expect(PaymentDetail.all.count).to eq(1)
    pay.destroy
    expect(PaymentDetail.all.count).to eq(0)
  end

  describe "with a completed payment" do
    let (:payment) { FactoryGirl.create(:payment, completed: true) }

    it "can determine the total received" do
      FactoryGirl.create(:payment_detail, payment: payment, amount: 15.33)
      payment.reload
      expect(Payment.total_received).to eq(15.33)
    end

    it "returns the set of paid expense_items" do
      pd = FactoryGirl.create(:payment_detail, payment: payment, amount: 15.33)
      payment.reload
      expect(Payment.paid_expense_items).to eq([pd.expense_item])
    end

    describe "with a refund" do
      before(:each) do
        pd = FactoryGirl.create(:payment_detail, payment: payment, amount: 15.33)
        @ref = FactoryGirl.create(:refund)
        @rd = FactoryGirl.create(:refund_detail, refund: @ref, payment_detail: pd)
        payment.reload
      end

      it "doesn't list the item in the paid_expense_items" do
        expect(Payment.paid_expense_items).to eq([])
      end
    end
  end

  describe "a payment for a tshirt" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail, payment: @pay)
      @pay.reload
      @reg = @pd.registrant
      @rei = FactoryGirl.create(:registrant_expense_item, registrant: @reg, expense_item: @pd.expense_item, free: @pd.free, details: @pd.details)
      @reg.reload
    end

    it "registrant owes for this item" do
      expect(@reg.owing_expense_items).to eq([@rei.expense_item])
    end
    describe "when the user has a free t-shirt and a paid t-shirt" do
      before(:each) do
        @rei_free = FactoryGirl.create(:registrant_expense_item, registrant: @reg, expense_item: @pd.expense_item, free: true)
        @reg.reload
      end

      it "markes the correct one as paid when we pay for the non-free one" do
        @pay.completed = true
        @pay.save
        expect(@reg.owing_registrant_expense_items).to eq([@rei_free])
      end
      it "markes the correct one as paid when we pay for the free one" do
        @pd.free = true
        @pd.save
        @pay.completed = true
        @pay.save
        expect(@reg.reload.owing_registrant_expense_items).to eq([@rei])
      end
    end
    describe "when the registrant has two t-shirts, who only differ by details" do
      before(:each) do
        @rei2 = FactoryGirl.create(:registrant_expense_item, registrant: @reg, expense_item: @pd.expense_item, details: "for My Kid")
        @reg.reload
      end

      it "marks the correct shirt as paid" do
        @pd.save
        @pay.completed = true
        @pay.save
        expect(@reg.reload.owing_registrant_expense_items).to eq([@rei2])
      end
    end

    describe "when the payment has empty details, and the registrant_expense_item has empty details" do
      before(:each) do
        @rei.details = ""
        @rei.save
        @pd.details = ""
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant no longer owes" do
        expect(@reg.reload.owing_expense_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_expense_items).to eq([@pd.expense_item])
      end
    end

    describe "when the payment has different details that the reg expense item details" do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        @rei.details = "original"
        @rei.save
        @pd.details = "reported"
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant still owes" do
        expect(@reg.owing_expense_items).to eq([@rei.expense_item])
      end

      it "registrant has paid item" do
        expect(@reg.paid_expense_items).to eq([@pd.expense_item])
      end

      it "should email the admin" do
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
        mail = ActionMailer::Base.deliveries.first
        expect(mail.subject).to eq("Missing reg-item match")
      end
    end

    describe "when the payment has empty details, vs nil details" do
      before(:each) do
        @rei.details = nil
        @rei.save
        @pd.details = ""
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant no longer owes" do
        expect(@reg.reload.owing_expense_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_expense_items).to eq([@pd.expense_item])
      end
    end

    describe "when the payment is paid" do
      before(:each) do
        @pay.completed = true
        @pay.save
      end
      it "registrant no longer owes" do
        expect(@reg.owing_expense_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_expense_items).to eq([@pd.expense_item])
      end

      describe "when the payment is saved after being paid" do
        before(:each) do
          @rei2 = FactoryGirl.create(:registrant_expense_item, registrant: @reg, expense_item: @pd.expense_item)
          @pay.save
          @reg.reload
        end
        it "doesn't remove more items from the registrant_expenses" do
          expect(@reg.owing_expense_items).to eq([@rei2.expense_item])
        end
      end
    end
  end
  describe "when paying for registration item" do
    before(:each) do
      @reg_period = FactoryGirl.create(:registration_period)
      @pay = FactoryGirl.create(:payment)
      @pd = FactoryGirl.create(:payment_detail, payment: @pay, amount: @reg_period.competitor_expense_item.cost)

      @reg_with_reg_item = FactoryGirl.create(:competitor)
      @pd.registrant = @reg_with_reg_item
      @pd.expense_item  = @reg_period.competitor_expense_item
      @pd.save
    end

    it "initially has the reg_item" do
      expect(@reg_with_reg_item.registrant_expense_items.count).to eq(1)
      expect(@reg_with_reg_item.registrant_expense_items.first.expense_item).to eq(@reg_period.competitor_expense_item)
    end

    it "sends no e-mail" do
      ActionMailer::Base.deliveries.clear
      @pay.reload
      @pay.completed = true
      @pay.save
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(0)
    end
  end
end
