class RemoveAdminVisibleFromExpenseGroup < ActiveRecord::Migration
  def change
    remove_column :expense_groups, :admin_visible, :boolean, default: false
  end
end
