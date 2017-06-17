class AddVerificationToTenantAliases < ActiveRecord::Migration
  def up
    add_column :tenant_aliases, :verified, :boolean, default: false
    execute "UPDATE tenant_aliases SET verified = true"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
