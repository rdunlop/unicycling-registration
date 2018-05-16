class AddAdminUpgradeCodeToTenant < ActiveRecord::Migration[4.2]
  def change
    add_column :tenants, :admin_upgrade_code, :string
  end
end
