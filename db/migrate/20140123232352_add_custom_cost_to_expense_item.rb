class AddCustomCostToExpenseItem < ActiveRecord::Migration
  def change
    add_column :expense_items, :has_custom_cost, :boolean, default: false
    add_column :registrant_expense_items, :custom_cost, :decimal
  end
end
