class InitiallyRegistrationIsClosed < ActiveRecord::Migration
  def change
    add_column :event_configurations, :under_construction, :boolean
    # Set existing EventConfigurations to have under_construction false
    change_column_null :event_configurations, :under_construction, false, false
    change_column_default :event_configurations, :under_construction, true
  end
end
