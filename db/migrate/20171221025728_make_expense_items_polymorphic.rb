class MakeExpenseItemsPolymorphic < ActiveRecord::Migration[5.1]
  def up
    remove_index :payment_details, :expense_item_id
    rename_column :payment_details, :expense_item_id, :line_item_id
    add_column :payment_details, :line_item_type, :string
    add_index :payment_details, %i[line_item_id line_item_type]

    remove_index :registrant_expense_items, :expense_item_id
    rename_column :registrant_expense_items, :expense_item_id, :line_item_id
    add_column :registrant_expense_items, :line_item_type, :string
    add_index :registrant_expense_items, %i[line_item_id line_item_type], name: "registrant_expense_items_line_item"

    execute "UPDATE payment_details SET line_item_type = 'ExpenseItem'"
    execute "UPDATE registrant_expense_items SET line_item_type = 'ExpenseItem'"
  end

  def down
    execute "DELETE FROM payment_details WHERE line_item_type != 'ExpenseItem'"
    execute "DELETE FROM registrant_expense_items WHERE line_item_type != 'ExpenseItem'"

    remove_index :payment_details, %i[line_item_id line_item_type]
    remove_column :payment_details, :line_item_type
    rename_column :payment_details, :line_item_id, :expense_item_id
    add_index :payment_details, :expense_item_id

    remove_index :registrant_expense_items, %i[line_item_id line_item_type]
    remove_column :registrant_expense_items, :line_item_type
    rename_column :registrant_expense_items, :line_item_id, :expense_item_id
    add_index :registrant_expense_items, :expense_item_id
  end
end
