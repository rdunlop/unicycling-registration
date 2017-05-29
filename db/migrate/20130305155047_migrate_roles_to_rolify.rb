class MigrateRolesToRolify < ActiveRecord::Migration
  def up
    remove_column :users, :admin
    remove_column :users, :super_admin
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
