class CreateTieBreakAdjustment < ActiveRecord::Migration
  def change
    create_table :tie_break_adjustments do |t|
      t.integer :tie_break_place
      t.references :judge
      t.references :competitor
      t.timestamps
    end
    add_index "tie_break_adjustments", ["competitor_id"], :name => "index_tie_break_adjustments_competitor_id"
    add_index "tie_break_adjustments", ["judge_id"], :name => "index_tie_break_adjustments_judge_id"
  end
end
