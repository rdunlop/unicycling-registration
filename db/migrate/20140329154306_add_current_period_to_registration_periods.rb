class AddCurrentPeriodToRegistrationPeriods < ActiveRecord::Migration
  def change
    add_column :registration_periods, :current_period, :boolean, default: false
  end
end
