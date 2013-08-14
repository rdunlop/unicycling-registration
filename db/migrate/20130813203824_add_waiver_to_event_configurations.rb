class AddWaiverToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :waiver, :boolean
  end
end
