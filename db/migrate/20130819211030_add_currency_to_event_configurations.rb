class AddCurrencyToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :currency, :text
  end
end
