# == Schema Information
#
# Table name: registrant_expense_items
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  expense_item_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  details         :string(255)
#  free            :boolean          default(FALSE)
#  system_managed  :boolean          default(FALSE)
#  locked          :boolean          default(FALSE)
#  custom_cost     :decimal(, )
#
# Indexes
#
#  index_registrant_expense_items_expense_item_id  (expense_item_id)
#  index_registrant_expense_items_registrant_id    (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_expense_item do
    registrant #FactoryGirl
    expense_item #FactoryGirl
    system_managed false
  end
end
