class AddDetailsToRegistrantExpenseItem < ActiveRecord::Migration
  def change
    add_column :registrant_expense_items, :details, :string
    add_column :expense_items, :has_details, :boolean
    add_column :expense_items, :details_label, :string
  end
end
