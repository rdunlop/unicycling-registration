class AddConfirmedEventsToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :display_confirmed_events, :boolean, default: false
  end
end
