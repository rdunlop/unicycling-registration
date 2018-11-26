# == Schema Information
#
# Table name: coupon_codes
#
#  id                     :integer          not null, primary key
#  name                   :string
#  code                   :string
#  description            :string
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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :coupon_code do
    sequence(:name) { |n| "the Coupon #{n}" }
    sequence(:code) { |n| "code #{n}" }
    sequence(:description) { |n| "description #{n}" }
    max_num_uses { 0 }
    price { 10.00 }
  end
end
