class AddArtisticBooleanToEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :artistic, :boolean, default: :false
  end
end
