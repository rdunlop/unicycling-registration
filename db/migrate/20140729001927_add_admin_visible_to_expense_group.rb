class AddAdminVisibleToExpenseGroup < ActiveRecord::Migration
  def change
    add_column :expense_groups, :admin_visible, :boolean, default: false
  end
end
