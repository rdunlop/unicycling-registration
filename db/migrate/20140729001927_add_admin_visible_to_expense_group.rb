class AddAdminVisibleToExpenseGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_groups, :admin_visible, :boolean, default: false
  end
end
