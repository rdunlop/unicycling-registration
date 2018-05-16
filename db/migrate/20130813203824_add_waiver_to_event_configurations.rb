class AddWaiverToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :waiver, :boolean
  end
end
