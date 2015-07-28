class CreateHeatLaneResultsTable < ActiveRecord::Migration
  def change
    create_table :heat_lane_results do |t|
      t.integer :competition_id, null: false
      t.integer :heat, null: false
      t.integer :lane, null: false
      t.string :status, null: false
      t.integer :minutes, null: false
      t.integer :seconds, null: false
      t.integer :thousands, null: false
      t.string :raw_data
      t.datetime :entered_at, null: false
      t.integer :entered_by_id, null: false
      t.timestamps
    end

    add_column :time_results, :heat_lane_result_id, :integer
  end
end
