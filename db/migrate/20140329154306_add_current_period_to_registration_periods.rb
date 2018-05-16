class AddCurrentPeriodToRegistrationPeriods < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_periods, :current_period, :boolean, default: false
  end
end
