class AddExpenseGroupToExpenseItem < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_items, :expense_group_id, :integer
  end
end
