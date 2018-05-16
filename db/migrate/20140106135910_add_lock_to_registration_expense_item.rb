class AddLockToRegistrationExpenseItem < ActiveRecord::Migration[4.2]
  def change
    add_column :registrant_expense_items, :locked, :boolean, default: false
  end
end
