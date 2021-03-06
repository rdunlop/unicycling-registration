require 'spec_helper'

describe CouponApplier do
  before do
    # so that registrants have ages:
    FactoryBot.create(:event_configuration, start_date: Date.current)
  end

  let(:expense_item) { FactoryBot.create(:expense_item) }
  let(:max_coupon_uses) { 0 }
  let(:coupon_code) { FactoryBot.create(:coupon_code, max_num_uses: max_coupon_uses) }
  let!(:coupon_code_detail) { FactoryBot.create(:coupon_code_expense_item, coupon_code: coupon_code, expense_item: expense_item) }
  let(:coupon_code_string) { coupon_code.code }
  let(:payment) { FactoryBot.create(:payment, :completed) }
  let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment, line_item: expense_item) }
  let(:subject) { described_class.new(payment.reload, coupon_code_string) }
  let(:do_action) { subject.perform }

  it "creates the association" do
    do_action
    expect(payment.payment_details.first.payment_detail_coupon_code).to be_present
    expect(subject.error).to be_nil
  end

  describe "when the code is typed in uppercase" do
    let(:coupon_code_string) { coupon_code.code.upcase }

    it "finds matching coupon even still" do
      do_action
      expect(payment.payment_details.first.payment_detail_coupon_code).to be_present
    end
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

  describe "when a maximum registrant age is specified" do
    let(:coupon_code) { FactoryBot.create(:coupon_code, maximum_registrant_age: 20) }
    let!(:payment_detail) do
      FactoryBot.create(:payment_detail,
                        payment: payment,
                        registrant: registrant,
                        line_item: expense_item)
    end

    context "on a 21 year old" do
      let(:registrant) { FactoryBot.create(:competitor, birthday: 21.years.ago) }

      it "doesn't allow the coupon to be used" do
        do_action
        expect(subject.error).to eq("Coupon Code not applicable to this order")
        expect(subject.applied_count).to eq(0)
      end
    end

    context "on a 20 year old" do
      let(:registrant) { FactoryBot.create(:competitor, birthday: 20.years.ago) }

      it "does allow the coupon to be used on a 20 year old" do
        do_action
        expect(subject.error).to be_nil
        expect(subject.applied_count).to eq(1)
      end
    end
  end

  describe "with a max number of applications" do
    let(:max_coupon_uses) { 1 }

    it "allows the first application" do
      do_action
      expect(subject.error).to be_nil
    end

    describe "when it has already reached its limit" do
      before { do_action }

      let(:new_payment) { FactoryBot.create(:payment) }
      let!(:new_payment_detail) { FactoryBot.create(:payment_detail, payment: new_payment, line_item: expense_item) }

      it "doesn't allow being applied again" do
        act = described_class.new(new_payment.reload, coupon_code_string)
        act.perform
        expect(act.error).to eq("Coupon limit reached")
      end
    end
  end
end
