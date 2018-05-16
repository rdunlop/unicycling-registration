class AddScheduledTimeToHeatTimesTable < ActiveRecord::Migration[4.2]
  def change
    add_column :heat_times, :scheduled_time, :string
  end
end
