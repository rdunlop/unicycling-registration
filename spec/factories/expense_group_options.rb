FactoryBot.define do
  factory :expense_group_option do
    expense_group # FactoryBot
    registrant_type { "competitor" }
    option { ExpenseGroupOption::ONE_IN_GROUP_REQUIRED }
  end
end

# == Schema Information
#
# Table name: expense_group_options
#
#  id               :integer          not null, primary key
#  expense_group_id :integer          not null
#  registrant_type  :string           not null
#  option           :string           not null
#  min_age          :integer
#  max_age          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_expense_group_options_on_expense_group_id  (expense_group_id)
#
