# == Schema Information
#
# Table name: coupon_code_expense_items
#
#  id              :integer          not null, primary key
#  coupon_code_id  :integer
#  expense_item_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_coupon_code_expense_items_on_coupon_code_id   (coupon_code_id)
#  index_coupon_code_expense_items_on_expense_item_id  (expense_item_id)
#

class CouponCodeExpenseItem < ApplicationRecord
  belongs_to :coupon_code, inverse_of: :coupon_code_expense_items, touch: true
  belongs_to :line_item, polymorphic: true, inverse_of: :coupon_code_expense_items

  validates :coupon_code, :line_item, presence: true

  delegate :to_s, to: :line_item
end
