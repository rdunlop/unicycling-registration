class AddOfflinePaymentDetails < ActiveRecord::Migration
  def up
    add_column :event_configurations, :paypal_mode, :string, default: "disabled"
    execute "UPDATE event_configurations SET paypal_mode = 'test' WHERE paypal_test = true"
    execute "UPDATE event_configurations SET paypal_mode = 'enabled' WHERE paypal_test = false"
    remove_column :event_configurations, :paypal_test

    add_column :event_configurations, :offline_payment, :boolean, default: false, null: false
    add_column :event_configuration_translations, :offline_payment_description, :text
  end

  def down
    add_column :event_configurations, :paypal_test, :boolean, default: true, null: false
    execute "UPDATE event_configurations SET paypal_test = true WHERE paypal_mode = 'test'"
    execute "UPDATE event_configurations SET paypal_test = false WHERE paypal_mode <> 'test'"
    remove_column :event_configurations, :paypal_mode

    remove_column :event_configurations, :offline_payment
    remove_column :event_configuration_translations, :offline_payment_description
  end
end
