class RemoveCurrencyFromEventConfigurations < ActiveRecord::Migration
  def up
    remove_column :event_configurations, :currency
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
