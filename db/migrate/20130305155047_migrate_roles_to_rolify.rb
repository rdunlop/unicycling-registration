class MigrateRolesToRolify < ActiveRecord::Migration
  def change
    remove_column :users, :admin
    remove_column :users, :super_admin
  end
end
