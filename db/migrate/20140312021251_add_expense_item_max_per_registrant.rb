class AddExpenseItemMaxPerRegistrant < ActiveRecord::Migration
  def change
    add_column :expense_items, :maximum_per_registrant, :integer, :default => 0
  end
end
