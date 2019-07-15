class AddToggleForMultiLapResultsDisplay < ActiveRecord::Migration[5.1]
  def change
    add_column :competitions, :hide_max_laps_count, :boolean, default: false, null: false
  end
end
