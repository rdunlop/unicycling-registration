class CreateTenantModel < ActiveRecord::Migration[4.2]
  def change
    create_table :tenants do |t|
      t.string :subdomain
      t.string :description
      t.timestamps
    end

    add_index :tenants, :subdomain
  end
end
