# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  completed      :boolean
#  cancelled      :boolean
#  transaction_id :string(255)
#  completed_date :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  payment_date   :string(255)
#  note           :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    user # FactoryGirl
    completed false
    cancelled false
    transaction_id "MyString"
    completed_date "2012-11-23 03:22:05"
  end
end
