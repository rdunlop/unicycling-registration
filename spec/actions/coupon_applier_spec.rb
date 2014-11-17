require 'spec_helper'

describe CouponApplier do
  let(:expense_item) { FactoryGirl.create(:expense_item) }
  let(:coupon_code) { FactoryGirl.create(:coupon_code) }
  let!(:coupon_code_detail) { FactoryGirl.create(:coupon_code_expense_item, coupon_code: coupon_code, expense_item: expense_item)}
  let(:coupon_code_string) { coupon_code.code }
  let(:payment) { FactoryGirl.create(:payment) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, expense_item: expense_item) }
  let(:subject) { described_class.new(payment.reload, coupon_code_string) }
  let(:do_action) { subject.perform }

  it "creates the association" do
    do_action
    expect(payment.payment_details.first.payment_detail_coupon_code).to be_present
    expect(subject.error).to be_nil
  end

  describe "when coupon code invalid" do
    let(:coupon_code_string) { "fake" }
     it "returns an error" do
      do_action
      expect(subject.error).to eq("Coupon Code not found")
    end
  end

  describe "if no matching coupon application" do
    let!(:coupon_code_detail) { nil }

    it "returns an error" do
      do_action
      expect(subject.error).to eq("Coupon Code not applicable to this order")
    end
  end
end
