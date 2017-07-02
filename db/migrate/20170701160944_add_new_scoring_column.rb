class AddNewScoringColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :val_5, :decimal, precision: 5, scale: 3
    execute "UPDATE scores SET val_5 = 0"
    add_column :judge_types, :val_5_description, :string
    add_column :judge_types, :val_5_max, :integer
    execute "UPDATE judge_types SET val_5_max = 0, val_5_description = 'N/A'"
  end
end
