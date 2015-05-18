class RenameHeatToWave < ActiveRecord::Migration
  def change
    rename_column :competitors, :heat, :wave
    rename_column :heat_times, :heat, :wave
    rename_table :heat_times, :wave_times
  end
end
