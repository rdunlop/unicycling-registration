class AddAwardAlternatesToEventConfigurations < ActiveRecord::Migration[8.1]
  def up
    add_column :event_configurations, :award_alternates, :boolean
    # Backfill existing rows to false — behavior for existing conventions is unchanged
    change_column_null :event_configurations, :award_alternates, false, false
    # New rows (including new tenants) default to true
    change_column_default :event_configurations, :award_alternates, true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
