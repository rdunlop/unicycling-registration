# == Schema Information
#
# Table name: refund_details
#
#  id                :integer          not null, primary key
#  refund_id         :integer
#  payment_detail_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_refund_details_on_payment_detail_id  (payment_detail_id) UNIQUE
#  index_refund_details_on_refund_id          (refund_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :refund_detail do
    refund # FactoryBot
    payment_detail # FactoryBot
  end
end
