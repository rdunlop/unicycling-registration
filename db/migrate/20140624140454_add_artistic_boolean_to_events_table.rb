class AddArtisticBooleanToEventsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :artistic, :boolean, default: false
  end
end
