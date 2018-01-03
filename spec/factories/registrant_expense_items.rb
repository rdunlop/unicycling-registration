# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  line_item_id      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#  line_item_type    :string
#
# Indexes
#
#  index_registrant_expense_items_registrant_id  (registrant_id)
#  registrant_expense_items_line_item            (line_item_id,line_item_type)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_expense_item do
    registrant # FactoryGirl
    association(:line_item, factory: :expense_item) # FactoryGirl
    system_managed false
  end
end
