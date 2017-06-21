FactoryGirl.define do
  factory :expense_group_free_option do
    expense_group # FactoryGirl
    registrant_type "competitor"
    free_option "One Free In Group REQUIRED"
  end
end

# == Schema Information
#
# Table name: expense_group_free_options
#
#  id               :integer          not null, primary key
#  expense_group_id :integer          not null
#  registrant_type  :string           not null
#  free_option      :string           not null
#  min_age          :integer
#  max_age          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  free_options_group_reg_type                           (expense_group_id,registrant_type) UNIQUE
#  index_expense_group_free_options_on_expense_group_id  (expense_group_id)
#
