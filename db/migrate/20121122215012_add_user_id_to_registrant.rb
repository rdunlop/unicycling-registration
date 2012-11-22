class AddUserIdToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :user_id, :integer
  end
end
