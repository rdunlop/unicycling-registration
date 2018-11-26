# == Schema Information
#
# Table name: coupon_codes
#
#  id                     :integer          not null, primary key
#  name                   :string
#  code                   :string
#  description            :string
#  max_num_uses           :integer          default(0)
#  created_at             :datetime
#  updated_at             :datetime
#  inform_emails          :text
#  price_cents            :integer
#  maximum_registrant_age :integer
#
# Indexes
#
#  index_coupon_codes_on_code  (code) UNIQUE
#

require 'spec_helper'

describe CouponCode do
  let(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment) }
  let(:coup) { FactoryBot.create(:payment_detail_coupon_code, payment_detail: payment_detail) }
  let(:coupon_code) { coup.coupon_code }

  describe "with an unpaid applied coupon code" do
    let(:payment) { FactoryBot.create(:payment) }

    it "doesn't count the coupon" do
      expect(coupon_code.num_uses).to eq(0)
    end
  end

  describe "with a completed payment" do
    let(:payment) { FactoryBot.create(:payment, :completed) }

    it "counts the coupon" do
      expect(coupon_code.num_uses).to eq(1)
    end
  end

  describe "it doesn't allow multiple codes with different cases" do
    let!(:code1) { FactoryBot.create(:coupon_code, code: "HELLO") }

    it "doesn't allow downcase version" do
      code2 = FactoryBot.build(:coupon_code, code: "hello")
      expect(code2).to be_invalid
      expect(code2.errors).to include(:code)
    end
  end
end
