class AddDetailsToRegistrantExpenseItem < ActiveRecord::Migration[4.2]
  def change
    add_column :registrant_expense_items, :details, :string
    add_column :expense_items, :has_details, :boolean
    add_column :expense_items, :details_label, :string
  end
end
