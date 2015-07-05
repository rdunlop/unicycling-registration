class AddPaypalToEventConfigurations < ActiveRecord::Migration
  class EventConfiguration < ActiveRecord::Base
  end

  def up
    add_column :event_configurations, :paypal_account, :string
    add_column :event_configurations, :paypal_test, :boolean, default: true, null: false

    EventConfiguration.reset_column_information
    ec = EventConfiguration.first
    ec.update_attributes(paypal_account: Rails.application.secrets.paypal_account,
                         paypal_test: Rails.application.secrets.fetch(:paypal_test, false)) if ec.present?
  end

  def down
    remove_column :event_configurations, :paypal_account
    remove_column :event_configurations, :paypal_test
  end
end
