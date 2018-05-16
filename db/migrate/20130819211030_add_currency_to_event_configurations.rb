class AddCurrencyToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :currency, :text
  end
end
