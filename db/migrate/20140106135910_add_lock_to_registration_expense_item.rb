class AddLockToRegistrationExpenseItem < ActiveRecord::Migration
  def change
    add_column :registrant_expense_items, :locked, :boolean, :default => false
  end
end
