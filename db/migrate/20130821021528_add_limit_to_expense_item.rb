class AddLimitToExpenseItem < ActiveRecord::Migration
  def change
    add_column :expense_items, :maximum_available, :integer
  end
end
