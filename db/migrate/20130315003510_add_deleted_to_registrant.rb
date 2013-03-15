class AddDeletedToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :deleted, :boolean
  end
end
