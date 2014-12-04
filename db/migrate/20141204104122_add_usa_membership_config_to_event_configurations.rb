class AddUsaMembershipConfigToEventConfigurations < ActiveRecord::Migration
  def up
      add_column :event_configurations, :usa_membership_config, :boolean, :default => false
      execute "UPDATE event_configurations SET usa_membership_config = true WHERE usa = true"
  end
  def down
    remove_column :event_configurations, :usa_membership_config
  end
end
