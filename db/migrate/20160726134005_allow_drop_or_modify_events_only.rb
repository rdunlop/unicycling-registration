class AllowDropOrModifyEventsOnly < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :add_event_end_date, :datetime
  end
end
