class AddAddressRequiredToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :request_address, :boolean, default: true, null: false
    add_column :event_configurations, :request_emergency_contact, :boolean, default: true, null: false
    add_column :event_configurations, :request_responsible_adult, :boolean, default: true, null: false
  end
end
