class AddLimitToExpenseItem < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_items, :maximum_available, :integer
  end
end
