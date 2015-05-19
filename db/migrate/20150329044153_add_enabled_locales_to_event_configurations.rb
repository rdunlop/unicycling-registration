class AddEnabledLocalesToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :enabled_locales, :string, default: "en,fr", null: false
  end
end
