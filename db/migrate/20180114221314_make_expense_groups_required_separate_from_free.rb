class MakeExpenseGroupsRequiredSeparateFromFree < ActiveRecord::Migration[5.1]
  class ExpenseGroupFreeOption < ActiveRecord::Base
  end

  def up
    remove_index :expense_group_free_options, name: "free_options_group_reg_type"
    ExpenseGroupFreeOption.where(free_option: "One Free In Group REQUIRED").each do |free_option|
      # Split each element into 2 elements, one for required-ness, one for free-ness
      ExpenseGroupFreeOption.create!(
        free_option: "One In Group REQUIRED",
        expense_group_id: free_option.expense_group_id,
        registrant_type: free_option.registrant_type,
        min_age: free_option.min_age,
        max_age: free_option.max_age
      )
      free_option.update!(free_option: "One Free in Group")
    end

    rename_table :expense_group_free_options, :expense_group_options
    rename_column :expense_group_options, :free_option, :option
  end

  def down
    rename_column :expense_group_options, :option, :free_option
    rename_table :expense_group_options, :expense_group_free_options

    ExpenseGroupFreeOption.reset_column_information
    ExpenseGroupFreeOption.where(free_option: "One Free in Group").each do |free_option|
      free_option.update!(free_option: "One Free In Group REQUIRED")

      other_option = ExpenseGroupFreeOption.find_by(
        expense_group_id: free_option.expense_group_id,
        free_option: "One In Group REQUIRED"
      )

      other_option&.destroy
    end

    add_index :expense_group_free_options, %i[expense_group_id registrant_type], unique: true, name: "free_options_group_reg_type"
  end
end
