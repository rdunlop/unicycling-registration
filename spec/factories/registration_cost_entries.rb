FactoryGirl.define do
  factory :registration_cost_entry do
    association :expense_item, cost: 100
    association :registration_cost
  end
end

# == Schema Information
#
# Table name: registration_cost_entries
#
#  id                   :integer          not null, primary key
#  registration_cost_id :integer          not null
#  expense_item_id      :integer          not null
#  min_age              :integer
#  max_age              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_registration_cost_entries_on_registration_cost_id  (registration_cost_id)
#
