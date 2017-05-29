class DropRegistrationPeriodsTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :registration_periods
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
