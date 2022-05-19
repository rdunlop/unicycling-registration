class AllowCouponCodeForLineItems < ActiveRecord::Migration[5.2]
  def up
    add_column :coupon_code_expense_items, :line_item_type, :string
    remove_index :coupon_code_expense_items, :expense_item_id
    rename_column :coupon_code_expense_items, :expense_item_id, :line_item_id
    execute "UPDATE coupon_code_expense_items SET line_item_type = 'ExpenseItem'"
    add_index :coupon_code_expense_items, %i[line_item_id line_item_type], name: "coupon_code_line_item"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
