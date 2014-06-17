class ChangeExternalResultsToAllowFractions < ActiveRecord::Migration
  def change
    rename_column :external_results, :rank, :points
    change_column :external_results, :points, :decimal, precision: 6, scale: 3, null: false
  end
end
