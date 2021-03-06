class CreateTenantAliases < ActiveRecord::Migration[4.2]
  def change
    create_table :tenant_aliases do |t|
      t.integer :tenant_id, null: false
      t.string :website_alias, null: false, unique: true
      t.boolean :primary_domain, default: false, null: false
      t.timestamps
    end

    add_index :tenant_aliases, :website_alias
    add_index :tenant_aliases, %i[tenant_id primary_domain]
  end
end
