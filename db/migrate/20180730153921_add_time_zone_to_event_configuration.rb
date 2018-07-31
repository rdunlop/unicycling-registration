class AddTimeZoneToEventConfiguration < ActiveRecord::Migration[5.1]
  def change
    add_column :event_configurations, :time_zone, :string, default: "Central Time (US & Canada)"
  end
end
