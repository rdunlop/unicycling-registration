# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  wheel_size_id     :integer
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
end
