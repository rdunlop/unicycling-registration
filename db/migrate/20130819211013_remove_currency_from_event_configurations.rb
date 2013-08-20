class RemoveCurrencyFromEventConfigurations < ActiveRecord::Migration
  def change
    remove_column :event_configurations, :currency
  end
end
