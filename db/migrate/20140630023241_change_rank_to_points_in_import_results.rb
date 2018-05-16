class ChangeRankToPointsInImportResults < ActiveRecord::Migration[4.2]
  def up
    change_column :import_results, :rank, :decimal, precision: 6, scale: 3
    rename_column :import_results, :rank, :points
  end

  def down
    change_colimn :import_results, :points, :rank
    change_column :import_results, :rank, :integer
  end
end
