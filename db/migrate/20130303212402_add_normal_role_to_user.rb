class AddNormalRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :normal, :boolean
  end
end
