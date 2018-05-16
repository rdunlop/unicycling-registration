class AddUsaIufToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :usa, :boolean, default: false
    add_column :event_configurations, :iuf, :boolean, default: false
  end
end
