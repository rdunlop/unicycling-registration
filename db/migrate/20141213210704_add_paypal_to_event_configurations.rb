class AddPaypalToEventConfigurations < ActiveRecord::Migration[4.2]
  class EventConfiguration < ActiveRecord::Base
  end

  def up
    add_column :event_configurations, :paypal_account, :string
    add_column :event_configurations, :paypal_test, :boolean, default: true, null: false

    EventConfiguration.reset_column_information
    ec = EventConfiguration.first
    if ec.present?
      ec.update(paypal_account: Rails.configuration.paypal_account,
                paypal_test: Rails.configuration.fetch(:paypal_test, false))
    end
  end

  def down
    remove_column :event_configurations, :paypal_account
    remove_column :event_configurations, :paypal_test
  end
end
