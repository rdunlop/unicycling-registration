# == Schema Information
#
# Table name: coupon_codes
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  code                   :string(255)
#  description            :string(255)
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

class CouponCode < ActiveRecord::Base
  include CachedModel

  before_validation { |cc| cc.code = cc.code.downcase }

  validates :name, :code, :description, presence: true
  validates :code, uniqueness: true
  validates :max_num_uses, numericality: { greater_than_or_equal_to: 0 }
  validates :price_cents, presence: true

  monetize :price_cents

  has_many :coupon_code_expense_items, inverse_of: :coupon_code, dependent: :destroy
  has_many :expense_items, through: :coupon_code_expense_items
  has_many :payment_detail_coupon_codes, dependent: :restrict_with_exception

  accepts_nested_attributes_for :coupon_code_expense_items

  def applied_to_payment_details
    payment_detail_coupon_codes.completed.map(&:payment_detail)
  end

  def max_uses_reached?
    return false if max_num_uses == 0

    num_uses >= max_num_uses
  end

  def num_uses
    payment_detail_coupon_codes.completed.count
  end

  def to_s
    name
  end
end
