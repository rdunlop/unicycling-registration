# == Schema Information
#
# Table name: refund_details
#
#  id                :integer          not null, primary key
#  refund_id         :integer
#  payment_detail_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_refund_details_on_payment_detail_id  (payment_detail_id) UNIQUE
#  index_refund_details_on_refund_id          (refund_id)
#

require 'spec_helper'

describe RefundDetail do
  before(:each) do
    @rd = FactoryGirl.create(:refund_detail)
  end

  it "has a valid rd from factoryGirl" do
    expect(@rd.valid?).to eq(true)
  end

  it "requires a payment_detail" do
    @rd.payment_detail = nil
    expect(@rd.valid?).to eq(false)
  end

  describe "when there is an active registration_period", caching: true do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period)
    end
    it "re-creates the registration_expense_item successfully" do
      @reg = FactoryGirl.create(:competitor)
      expect(@reg.registrant_expense_items.count).to eq(1)
      @pd = FactoryGirl.create(:payment_detail, registrant: @reg, expense_item: @rp.competitor_expense_item)
      payment = @pd.payment
      payment.reload
      payment.completed = true
      payment.save
      @reg.reload
      expect(@reg.registrant_expense_items.count).to eq(0)

      @pd.reload
      @rd1 = FactoryGirl.create(:refund_detail, payment_detail: @pd)
      @reg.reload
      expect(@reg.registrant_expense_items.count).to eq(1)
    end

    describe "when there is a previous active registration_period", caching: true do
      before(:each) do
        @rp_prev = FactoryGirl.create(:registration_period, start_date: Date.new(2010, 1, 1), end_date: Date.new(2011, 1, 1))
      end

      it "Doesn't re-add any items if the refund is a non-system-managed item (not the competition item)" do
        @reg = FactoryGirl.create(:competitor)
        @pd = FactoryGirl.create(:payment_detail, registrant: @reg, expense_item: @rp_prev.competitor_expense_item)
        @pd2 = FactoryGirl.create(:payment_detail, registrant: @reg)
        payment = @pd.payment
        payment.reload
        payment.completed = true
        payment.save
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(0)

        @pd2.reload
        @rd1 = FactoryGirl.create(:refund_detail, payment_detail: @pd2)
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(0)
      end
    end
  end
end
