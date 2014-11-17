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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coupon_code do
    sequence(:name) { |n| "the Coupon #{n}" }
    sequence(:code) { |n| "code #{n}" }
    sequence(:description) { |n| "description #{n}" }
    max_num_uses 0
    price 10.00
  end
end
