class IncreaseRangeOfOverallPointsBreakdown < ActiveRecord::Migration[5.1]
  def change
    add_column :combined_competition_entries, :points_11, :integer
    add_column :combined_competition_entries, :points_12, :integer
    add_column :combined_competition_entries, :points_13, :integer
    add_column :combined_competition_entries, :points_14, :integer
    add_column :combined_competition_entries, :points_15, :integer
  end
end
