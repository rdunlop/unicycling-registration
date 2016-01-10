class AddSystemManagedToExpenseGroup < ActiveRecord::Migration
  def up
    add_column :expense_groups, :system_managed, :boolean, default: false, null: false
    execute "UPDATE expense_groups SET system_managed = registration_items"
  end

  def down
    drop_column :expense_groups, :system_managed
  end
end
