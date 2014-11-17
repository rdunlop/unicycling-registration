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

class CouponCodeExpenseItem < ActiveRecord::Base
  belongs_to :coupon_code, inverse_of: :coupon_code_expense_items
  belongs_to :expense_item

  validates :coupon_code, :expense_item, presence: true
end
