class AddClubStringToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :club, :string
  end
end
