# == Schema Information
#
# Table name: payment_details
#
#  id             :integer          not null, primary key
#  payment_id     :integer
#  registrant_id  :integer
#  created_at     :datetime
#  updated_at     :datetime
#  line_item_id   :integer
#  details        :string(255)
#  free           :boolean          default(FALSE), not null
#  refunded       :boolean          default(FALSE), not null
#  amount_cents   :integer
#  line_item_type :string
#
# Indexes
#
#  index_payment_details_on_line_item_id_and_line_item_type  (line_item_id,line_item_type)
#  index_payment_details_payment_id                          (payment_id)
#  index_payment_details_registrant_id                       (registrant_id)
#

require 'spec_helper'

describe PaymentDetail do
  before(:each) do
    @pd = FactoryGirl.create(:payment_detail, amount: 90)
  end

  it "can be cerated by factory" do
    expect(@pd.valid?).to eq(true)
  end

  it "must have a payment" do
    @pd.payment = nil
    expect(@pd.valid?).to eq(false)
  end

  it "does not allow negative amounts" do
    @pd.amount = -1
    expect(@pd.valid?).to eq(false)
  end

  it "must have a registrant" do
    @pd.registrant = nil
    expect(@pd.valid?).to eq(false)
  end

  it "must have an amount" do
    @pd.amount_cents = nil
    expect(@pd.valid?).to eq(false)
  end
  it "must have an item" do
    @pd.line_item = nil
    expect(@pd.valid?).to eq(false)
  end
  it "has additional description if it is refunded" do
    expect(@pd.refunded?).to eq(false)
    expect(@pd.to_s).to eq(@pd.line_item.to_s)
    @ref = FactoryGirl.create(:refund_detail, payment_detail: @pd)
    @pd.reload
    expect(@pd.refunded?).to eq(true)
    expect(@pd.to_s).to eq("#{@pd.line_item} (Refunded)")
  end

  it "indicates that it is a refund if it has an associated refund_detail" do
    expect(@pd.refunded?).to eq(false)
    @ref = FactoryGirl.create(:refund_detail, payment_detail: @pd)
    @pd.reload
    expect(@pd.refunded?).to eq(true)
    expect(@ref.percentage).to eq(100)
    expect(@pd.cost).to eq(0.to_money)
  end

  it "it marks the cost as partial if the refund is not 100%" do
    expect(@pd.refunded?).to eq(false)
    @refund_detail = FactoryGirl.create(:refund_detail, payment_detail: @pd)
    @refund = @refund_detail.refund
    @refund.percentage = 50
    @refund.save!
    @pd.reload
    expect(@pd.refunded?).to eq(true)
    expect(@pd.cost).to eq(45.to_money) # amount is 90, 50% of 90 is 45
  end

  it "is not refunded by default" do
    pay = PaymentDetail.new
    expect(pay.refunded?).to eq(false)
  end

  it "is not scoped as completed if not completed" do
    expect(@pd.payment.completed).to eq(false)
    expect(PaymentDetail.completed).to eq([])
  end

  describe "when a payment is completed" do
    before(:each) do
      pay = @pd.payment
      pay.completed = true
      pay.save!
    end
    it "is scoped as completed when payment is completed" do
      expect(PaymentDetail.completed).to eq([@pd])
    end

    it "doesn't list refunded payments" do
      @ref = FactoryGirl.create(:refund_detail, payment_detail: @pd)
      expect(PaymentDetail.not_refunded).to eq([])
      expect(PaymentDetail.refunded).to eq([@pd])
    end
  end

  describe "with a coupon code" do
    let(:coupon_code) { FactoryGirl.create(:coupon_code, price: 1.00) }

    it "discounts the payment_detail" do
      FactoryGirl.create(:payment_detail_coupon_code, payment_detail: @pd, coupon_code: coupon_code)
      @pd.recalculate!
      expect(@pd.amount).to eq(1.to_money)
    end
  end
end
