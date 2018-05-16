class AddNameToUsersTable < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :name, :string, default: nil
  end
end
