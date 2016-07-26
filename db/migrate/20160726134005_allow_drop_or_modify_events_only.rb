class AllowDropOrModifyEventsOnly < ActiveRecord::Migration
  def change
    add_column :event_configurations, :add_event_end_date, :datetime
  end
end
