class AddUserIdToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :user_id, :integer
  end
end
