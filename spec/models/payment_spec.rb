# == Schema Information
#
# Table name: payments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  completed            :boolean          default(FALSE), not null
#  cancelled            :boolean          default(FALSE), not null
#  transaction_id       :string
#  completed_date       :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  payment_date         :string
#  note                 :string
#  invoice_id           :string
#  offline_pending      :boolean          default(FALSE), not null
#  offline_pending_date :datetime
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

require 'spec_helper'
require 'cgi'

describe Payment do
  before do
    @pay = FactoryBot.create(:payment)
  end

  it "can be created by FactoryBot" do
    expect(@pay.valid?).to eq(true)
  end

  it "defaults completed to false" do
    p = described_class.new
    expect(p.completed).to eq(false)
  end

  it "defaults cancelled to false" do
    p = described_class.new
    expect(p.cancelled).to eq(false)
  end

  it "Requires user" do
    @pay.user = nil
    expect(@pay.valid?).to eq(false)
  end

  describe "with payment details" do
    before do
      @pd = FactoryBot.create(:payment_detail, payment: @pay, amount: 57.49)
      @pay.reload
    end

    it "has payment_details" do
      expect(@pay.payment_details).to eq([@pd])
    end
    it "can calcalate the payment total-amount" do
      @pd2 = FactoryBot.create(:payment_detail, payment: @pay, amount: 23.0)
      expect(@pay.total_amount == 80.49.to_money).to eq(true)
    end

    it "has a list of unique_payment_deatils" do
      expect(@pay.unique_payment_details).to eq([PaymentDetailSummary.new(line_item_id: @pd.line_item_id, line_item_type: @pd.line_item_type, count: 1, amount: @pd.amount)])
    end

    describe "with mulitple payment_details of the same expense_item" do
      before do
        @pd2 = FactoryBot.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details, line_item: @pd.line_item)
        @pd3 = FactoryBot.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details, line_item: @pd.line_item)
      end

      it "only lists the element once" do
        expect(@pay.unique_payment_details.count).to eq(1)
        expect(@pay.unique_payment_details).to eq([PaymentDetailSummary.new(line_item_id: @pd.line_item_id, line_item_type: @pd.line_item_type, count: 3, amount: @pd.amount)])
      end

      describe "with payment_details of different expense_items" do
        before do
          @pdb = FactoryBot.create(:payment_detail, payment: @pd.payment, amount: @pd.amount, details: @pd.details)
        end

        it "lists the entries separately" do
          expect(@pay.unique_payment_details.count).to eq(2)
        end
      end

      describe "with different amounts" do
        before do
          @pdc = FactoryBot.create(:payment_detail, payment: @pd.payment, amount: 99.98, details: @pd.details, line_item: @pd.line_item)
        end

        it "does not group them together" do
          expect(@pay.unique_payment_details.count).to eq(2)
          expect(@pay.unique_payment_details).to match_array([PaymentDetailSummary.new(line_item_id: @pd.line_item_id, line_item_type: @pd.line_item_type, count: 1, amount: @pdc.amount),
                                                              PaymentDetailSummary.new(line_item_id: @pd.line_item_id, line_item_type: @pd.line_item_type, count: 3, amount: @pd2.amount)])
        end
      end
    end
  end

  describe "With an environment config with test mode disabled" do
    let!(:event_configuration) { FactoryBot.create :event_configuration, paypal_mode: "enabled" }

    it "has a REAL paypal_post_url" do
      expect(@pay.paypal_post_url).to eq("https://www.paypal.com/cgi-bin/webscr")
    end
  end

  it "saves associated details when the payment is saved" do
    pay = FactoryBot.build(:payment)
    pd = pay.payment_details.build
    pd.registrant = FactoryBot.create(:registrant)
    pd.amount = 100
    pd.line_item = FactoryBot.create(:expense_item)
    expect(PaymentDetail.all.count).to eq(0)
    pay.save
    expect(PaymentDetail.all.count).to eq(1)
  end

  it "destroys related payment_details upon destroy" do
    pay = FactoryBot.create(:payment)
    FactoryBot.create(:payment_detail, payment: pay)
    pay.reload
    expect(PaymentDetail.all.count).to eq(1)
    pay.destroy
    expect(PaymentDetail.all.count).to eq(0)
  end

  describe "with a completed payment" do
    let(:payment) { FactoryBot.create(:payment, completed: true) }

    it "can determine the total received" do
      FactoryBot.create(:payment_detail, payment: payment, amount: 15.33)
      payment.reload
      expect(described_class.total_received).to eq(15.33.to_money)
    end

    describe "with a refund" do
      before do
        pd = FactoryBot.create(:payment_detail, payment: payment, amount: 15.33)
        @ref = FactoryBot.create(:refund)
        @rd = FactoryBot.create(:refund_detail, refund: @ref, payment_detail: pd)
        payment.reload
      end

      describe "#total_refunded_amount" do
        it "counts the payments" do
          expect(described_class.total_refunded_amount).to eq(0.to_money)
        end
      end
    end
  end

  describe "a payment for a tshirt" do
    before do
      @pd = FactoryBot.create(:payment_detail, payment: @pay)
      @pay.reload
      @reg = @pd.registrant
      @rei = FactoryBot.create(:registrant_expense_item, registrant: @reg, line_item: @pd.line_item, free: @pd.free, details: @pd.details)
      @reg.reload
    end

    it "registrant owes for this item" do
      expect(@reg.owing_line_items).to eq([@rei.line_item])
    end
    describe "when the user has a free t-shirt and a paid t-shirt" do
      before do
        @rei_free = FactoryBot.create(:registrant_expense_item, registrant: @reg, line_item: @pd.line_item, free: true)
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
      before do
        @rei2 = FactoryBot.create(:registrant_expense_item, registrant: @reg, line_item: @pd.line_item, details: "for My Kid")
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
      before do
        @rei.details = ""
        @rei.save
        @pd.details = ""
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant no longer owes" do
        expect(@reg.reload.owing_line_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_line_items).to eq([@pd.line_item])
      end
    end

    describe "when the payment has different details that the reg expense item details" do
      before do
        ActionMailer::Base.deliveries.clear
        @rei.details = "original"
        @rei.save
        @pd.details = "reported"
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant still owes" do
        expect(@reg.owing_line_items).to eq([@rei.line_item])
      end

      it "registrant has paid item" do
        expect(@reg.paid_line_items).to eq([@pd.line_item])
      end

      it "emails the admin" do
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
        mail = ActionMailer::Base.deliveries.first
        expect(mail.subject).to eq("Missing reg-item match")
      end
    end

    describe "when the payment has empty details, vs nil details" do
      before do
        @rei.details = nil
        @rei.save
        @pd.details = ""
        @pd.save
        @pay.completed = true
        @pay.save
      end

      it "registrant no longer owes" do
        expect(@reg.reload.owing_line_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_line_items).to eq([@pd.line_item])
      end
    end

    describe "when the payment is paid" do
      before do
        @pay.completed = true
        @pay.save
      end

      it "registrant no longer owes" do
        expect(@reg.owing_line_items).to eq([])
      end
      it "registrant has paid item" do
        expect(@reg.paid_line_items).to eq([@pd.line_item])
      end

      describe "when the payment is saved after being paid" do
        before do
          @rei2 = FactoryBot.create(:registrant_expense_item, registrant: @reg, line_item: @pd.line_item)
          @pay.save
          @reg.reload
        end

        it "doesn't remove more items from the registrant_expenses" do
          expect(@reg.owing_line_items).to eq([@rei2.line_item])
        end
      end
    end
  end

  describe "when paying for registration item" do
    before do
      @reg_cost = FactoryBot.create(:registration_cost, :competitor)
      @pay = FactoryBot.create(:payment)
      @pd = FactoryBot.create(:payment_detail, payment: @pay, amount: @reg_cost.expense_items.first.cost)

      @reg_with_reg_item = FactoryBot.create(:competitor)
      @pd.registrant = @reg_with_reg_item
      @pd.line_item = @reg_cost.expense_items.first
      @pd.save
    end

    it "initially has the reg_item" do
      expect(@reg_with_reg_item.registrant_expense_items.count).to eq(1)
      expect(@reg_with_reg_item.registrant_expense_items.first.line_item).to eq(@reg_cost.expense_items.first)
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
