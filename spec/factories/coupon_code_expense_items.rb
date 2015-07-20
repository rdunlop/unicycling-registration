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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coupon_code_expense_item do
    coupon_code # Factory Girl
    expense_item # Factory Girl
  end
end
