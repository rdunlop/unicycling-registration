class AddVerificationToTenantAliases < ActiveRecord::Migration
  def change
    add_column :tenant_aliases, :verified, :boolean, default: false
    execute "UPDATE tenant_aliases SET verified = true"
  end
end
