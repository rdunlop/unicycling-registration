class RemoveCurrencyLayoutFromEventConfiguration < ActiveRecord::Migration
  def change
    remove_column :event_configurations, :currency, :string, default: "%u%n"
  end
end
