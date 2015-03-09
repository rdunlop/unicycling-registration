# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean
#  details_label          :string(255)
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE)
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer
#
# Indexes
#
#  index_expense_items_expense_group_id  (expense_group_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_item do
    sequence(:name) {|n| "T-Shirt Size ##{n}" }
    cost "9.99"
    position 1
    expense_group # FactoryGirl
    has_details false
    has_custom_cost false
    details_label nil
    maximum_available nil
    maximum_per_registrant 0
  end
end
