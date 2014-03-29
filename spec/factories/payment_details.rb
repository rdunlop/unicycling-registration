# == Schema Information
#
# Table name: payment_details
#
#  id              :integer          not null, primary key
#  payment_id      :integer
#  registrant_id   :integer
#  amount          :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  expense_item_id :integer
#  details         :string(255)
#  free            :boolean          default(FALSE)
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
