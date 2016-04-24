class RemoveDefaultLanguagesFromEventConfigurations < ActiveRecord::Migration
  def up
    change_column_default :event_configurations, :enabled_locales, nil
  end

  def down
    change_column_default :event_configurations, :enabled_locales, "en,fr"
  end
end
