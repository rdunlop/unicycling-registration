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
# Indexes
#
#  index_payment_detail_coupon_codes_on_coupon_code_id     (coupon_code_id)
#  index_payment_detail_coupon_codes_on_payment_detail_id  (payment_detail_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_detail_coupon_code do
    payment_detail # FactoryGirl
    coupon_code # FactoryGirl
  end
end
