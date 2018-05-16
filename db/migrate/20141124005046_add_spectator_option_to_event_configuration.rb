class AddSpectatorOptionToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :spectators, :boolean, default: false
  end
end
