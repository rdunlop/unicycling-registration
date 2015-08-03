class CreateHeatLaneJudgeNotesTable < ActiveRecord::Migration
  def change
    create_table :heat_lane_judge_notes do |t|
      t.integer :competition_id, null: false, index: true
      t.integer :heat, null: false
      t.integer :lane, null: false
      t.string :status, null: false
      t.string :comments
      t.datetime :entered_at, null: false
      t.integer :entered_by_id, null: false
      t.timestamps
    end
  end
end
