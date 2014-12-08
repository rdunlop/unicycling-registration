class CreateTenantModel < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :subdomain
      t.string :description
      t.timestamps
    end

    add_index :tenants, :subdomain
  end
end
