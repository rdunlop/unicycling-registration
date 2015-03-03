class CreateRegistrationExpenseGroup < ActiveRecord::Migration
  class RegistrationPeriod < ActiveRecord::Base
  end

  class ExpenseItem < ActiveRecord::Base
  end

  def up
    add_column :expense_groups, :registration_items, :boolean, default: false, null: false

    RegistrationPeriod.reset_column_information
    ExpenseItem.reset_column_information
    expense_item_id = RegistrationPeriod.first.try(:competitor_expense_item_id)
    if expense_item_id
      expense_group_id = ExpenseItem.find(expense_item_id).try(:expense_group_id)
      execute "UPDATE expense_groups SET registration_items = true WHERE id = #{expense_group_id}"
    end
  end

  def down
    remove_column :expense_groups, :registration_items
  end
end
