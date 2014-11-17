# == Schema Information
#
# Table name: payment_detail_coupons
#
#  id                :integer          not null, primary key
#  payment_detail_id :integer
#  coupon_code_id    :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class PaymentDetailCoupon < ActiveRecord::Base
  validates :payment_detail, :coupon_code, presence: true
end
