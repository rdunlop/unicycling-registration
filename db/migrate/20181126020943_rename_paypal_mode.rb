class RenamePaypalMode < ActiveRecord::Migration[5.1]
  def change
    rename_column :event_configurations, :paypal_mode, :payment_mode
  end
end
