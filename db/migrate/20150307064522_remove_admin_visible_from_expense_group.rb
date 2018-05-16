class RemoveAdminVisibleFromExpenseGroup < ActiveRecord::Migration[4.2]
  def change
    remove_column :expense_groups, :admin_visible, :boolean, default: false
  end
end
