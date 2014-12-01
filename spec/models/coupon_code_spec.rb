# == Schema Information
#
# Table name: coupon_codes
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  code          :string(255)
#  description   :string(255)
#  max_num_uses  :integer          default(0)
#  price         :decimal(, )
#  created_at    :datetime
#  updated_at    :datetime
#  inform_emails :text
#

require 'spec_helper'

describe CouponCode do
  let(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment) }
  let(:coup) { FactoryGirl.create(:payment_detail_coupon_code, payment_detail: payment_detail) }
  let(:coupon_code) { coup.coupon_code }

  describe "with an unpaid applied coupon code" do
    let(:payment) { FactoryGirl.create(:payment) }

    it "doesn't count the coupon" do
      expect(coupon_code.num_uses).to eq(0)
    end
  end

  describe "with a completed payment" do
    let(:payment) { FactoryGirl.create(:payment, :completed) }

    it "counts the coupon" do
      expect(coupon_code.num_uses).to eq(1)
    end
  end

  describe "it doesn't allow multiple codes with different cases" do
    let!(:code1) { FactoryGirl.create(:coupon_code, code: "HELLO") }
    it "doesn't allow downcase version" do
      code2 = FactoryGirl.build(:coupon_code, code: "hello")
      expect(code2).to be_invalid
      expect(code2.errors).to include(:code)
    end
  end
end
