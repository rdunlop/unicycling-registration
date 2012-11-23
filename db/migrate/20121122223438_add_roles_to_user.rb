class AddRolesToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean
    add_column :users, :super_admin, :boolean
  end
end
