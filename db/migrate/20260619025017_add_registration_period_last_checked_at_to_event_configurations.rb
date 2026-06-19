class AddRegistrationPeriodLastCheckedAtToEventConfigurations < ActiveRecord::Migration[8.1]
  def change
    add_column :event_configurations, :registration_period_last_checked_at, :datetime
  end
end
