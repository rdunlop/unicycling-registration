class AddExpenseItemMaxPerRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_items, :maximum_per_registrant, :integer, default: 0
  end
end
