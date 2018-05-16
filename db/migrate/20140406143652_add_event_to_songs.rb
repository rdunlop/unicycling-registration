class AddEventToSongs < ActiveRecord::Migration[4.2]
  def change
    add_column :songs, :event_id, :integer
  end
end
