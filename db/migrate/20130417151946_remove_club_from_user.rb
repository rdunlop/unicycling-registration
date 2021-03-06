class RemoveClubFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :club_admin
    remove_column :users, :club
  end

  def down
    add_column :users, :club_admin, :boolean
    add_column :users, :club, :string
  end
end
