class AddAdminUpgradeCodeToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :admin_upgrade_code, :string
  end
end
