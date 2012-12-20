class AddExpenseGroupToExpenseItem < ActiveRecord::Migration
  def change
    add_column :expense_items, :expense_group_id, :integer
  end
end
