class AddNameToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, default: nil
  end
end
