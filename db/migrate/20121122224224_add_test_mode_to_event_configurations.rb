class AddTestModeToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :test_mode, :boolean
  end
end
