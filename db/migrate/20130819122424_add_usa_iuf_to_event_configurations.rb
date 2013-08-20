class AddUsaIufToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :usa, :boolean, :default => false
    add_column :event_configurations, :iuf, :boolean, :default => false
  end
end
