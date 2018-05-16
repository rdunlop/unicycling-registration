class AddNormalRoleToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :normal, :boolean
  end
end
