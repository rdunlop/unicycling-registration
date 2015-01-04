# == Schema Information
#
# Table name: payment_detail_coupon_codes
#
#  id                :integer          not null, primary key
#  payment_detail_id :integer
#  coupon_code_id    :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class PaymentDetailCouponCode < ActiveRecord::Base
  belongs_to :coupon_code
  belongs_to :payment_detail
  validates :payment_detail, :coupon_code, presence: true

  delegate :price, to: :coupon_code
  delegate :to_s, to: :coupon_code

  def self.completed
    joins(payment_detail: :payment).merge(Payment.completed)
  end

  def inform?
    coupon_code.inform_emails?
  end
end
