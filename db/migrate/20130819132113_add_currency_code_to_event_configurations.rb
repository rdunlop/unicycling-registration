class AddCurrencyCodeToEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :currency_code, :string
  end
end
