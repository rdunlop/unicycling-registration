# == Schema Information
#
# Table name: coupon_codes
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  code         :string(255)
#  description  :string(255)
#  max_num_uses :integer          default(0)
#  price        :decimal(, )
#  created_at   :datetime
#  updated_at   :datetime
#

class CouponCode < ActiveRecord::Base
  validates :name, :code, :description, presence: true
  validates :max_num_uses, numericality: { greater_than_or_equal_to: 0 }
  validates :price, presence: true
  has_many :coupon_code_expense_items
  has_many :expense_items, through: :coupon_code_expense_items

  accepts_nested_attributes_for :coupon_code_expense_items

  def to_s
    name
  end
end
