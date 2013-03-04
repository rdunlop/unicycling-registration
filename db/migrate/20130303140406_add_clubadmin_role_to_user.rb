class AddClubadminRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :club_admin, :boolean
  end
end
