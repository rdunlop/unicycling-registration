class AddSpectatorOptionToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :spectators, :boolean, default: false
  end
end
