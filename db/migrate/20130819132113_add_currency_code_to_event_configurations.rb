class AddCurrencyCodeToEventConfigurations < ActiveRecord::Migration
  def change
    add_column :event_configurations, :currency_code, :string
  end
end
