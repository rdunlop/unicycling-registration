# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  description            :string(255)
#  cost                   :decimal(, )
#  export_name            :string(255)
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean
#  details_label          :string(255)
#  maximum_available      :integer
#  tax_percentage         :decimal(5, 3)    default(0.0)
#  has_custom_cost        :boolean          default(FALSE)
#  maximum_per_registrant :integer          default(0)
#
# Indexes
#
#  index_expense_items_expense_group_id  (expense_group_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_item do
    sequence(:name) {|n| "T-Shirt Size ##{n}" }
    description "TShirt Small"
    cost "9.99"
    export_name "t_shirt_small"
    position 1
    expense_group # FactoryGirl
    has_details false
    has_custom_cost false
    details_label nil
    maximum_available nil
    maximum_per_registrant 0
  end
end
