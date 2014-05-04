class AddStartTimeIndicatorToTimeResults < ActiveRecord::Migration
  def change
    add_column :time_results, :is_start_time, :boolean, default: false
    add_column :import_results, :is_start_time, :boolean, default: false
  end
end
