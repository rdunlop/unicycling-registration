class AddHeatLaneToImportResults < ActiveRecord::Migration
  def change
    add_column :import_results, :heat, :integer, default: nil
    add_column :import_results, :lane, :integer, default: nil
  end
end
