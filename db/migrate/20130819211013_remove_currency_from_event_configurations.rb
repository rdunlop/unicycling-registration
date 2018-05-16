class RemoveCurrencyFromEventConfigurations < ActiveRecord::Migration[4.2]
  def up
    remove_column :event_configurations, :currency
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
