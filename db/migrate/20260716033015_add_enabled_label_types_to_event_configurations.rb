class AddEnabledLabelTypesToEventConfigurations < ActiveRecord::Migration[8.1]
  def change
    add_column :event_configurations, :enabled_label_types, :string
  end
end
