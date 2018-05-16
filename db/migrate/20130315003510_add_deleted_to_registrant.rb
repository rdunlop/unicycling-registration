class AddDeletedToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :deleted, :boolean
  end
end
