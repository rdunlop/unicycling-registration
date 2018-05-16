class AddTestModeToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :test_mode, :boolean
  end
end
