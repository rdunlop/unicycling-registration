# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  completed      :boolean          default(FALSE), not null
#  cancelled      :boolean          default(FALSE), not null
#  transaction_id :string(255)
#  completed_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  payment_date   :string(255)
#  note           :string(255)
#  invoice_id     :string(255)
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    user # FactoryGirl
    completed false
    cancelled false
    transaction_id "MyString"
    completed_date  nil
    sequence(:invoice_id) {|n| "INVOICE #{n}" }

    trait :completed do
      completed true
      completed_date "2012-11-23 03:22:05"
    end
  end
end
