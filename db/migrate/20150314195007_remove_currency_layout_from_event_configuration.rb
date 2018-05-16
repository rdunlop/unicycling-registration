class RemoveCurrencyLayoutFromEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    remove_column :event_configurations, :currency, :string, default: "%u%n"
  end
end
