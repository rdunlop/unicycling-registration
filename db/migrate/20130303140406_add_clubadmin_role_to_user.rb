class AddClubadminRoleToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :club_admin, :boolean
  end
end
