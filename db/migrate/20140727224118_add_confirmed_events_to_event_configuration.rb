class AddConfirmedEventsToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :display_confirmed_events, :boolean, default: false
  end
end
