class DropRegistrationPeriodsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :registration_periods
  end
end
