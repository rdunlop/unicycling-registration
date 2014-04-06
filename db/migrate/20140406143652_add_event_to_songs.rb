class AddEventToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :event_id, :integer
  end
end
