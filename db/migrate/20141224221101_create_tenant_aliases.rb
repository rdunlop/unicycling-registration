class CreateTenantAliases < ActiveRecord::Migration
  def change
    create_table :tenant_aliases do |t|
      t.integer :tenant_id, null: false
      t.string :website_alias, null: false, unique: true
      t.boolean :primary_domain, default: false, null: false
      t.timestamps
    end

    add_index :tenant_aliases, :website_alias
    add_index :tenant_aliases, [:tenant_id, :primary_domain]
  end
end
