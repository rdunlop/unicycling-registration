class AddVerificationToTenantAliases < ActiveRecord::Migration[4.2]
  def up
    add_column :tenant_aliases, :verified, :boolean, default: false
    execute "UPDATE tenant_aliases SET verified = true"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
