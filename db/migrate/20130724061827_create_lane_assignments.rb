class CreateLaneAssignments < ActiveRecord::Migration
  def change
    create_table :lane_assignments do |t|
      t.integer :competition_id
      t.integer :registrant_id
      t.integer :heat
      t.integer :lane

      t.timestamps
    end
  end
end
