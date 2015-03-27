# == Schema Information
#
# Table name: payment_details
#
#  id              :integer          not null, primary key
#  payment_id      :integer
#  registrant_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#  expense_item_id :integer
#  details         :string(255)
#  free            :boolean          default(FALSE), not null
#  refunded        :boolean          default(FALSE), not null
#  amount_cents    :integer
#
# Indexes
#
#  index_payment_details_expense_item_id  (expense_item_id)
#  index_payment_details_payment_id       (payment_id)
#  index_payment_details_registrant_id    (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_detail do
    payment # FactoryGirl
    registrant # FactoryGirl
    amount "9.99"
    expense_item # FactoryGirl
  end
end
