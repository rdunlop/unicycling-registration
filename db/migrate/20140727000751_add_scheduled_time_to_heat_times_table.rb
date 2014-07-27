class AddScheduledTimeToHeatTimesTable < ActiveRecord::Migration
  def change
    add_column :heat_times, :scheduled_time, :string
  end
end
