class AddHeatLaneToImportResults < ActiveRecord::Migration[4.2]
  def change
    add_column :import_results, :heat, :integer, default: nil
    add_column :import_results, :lane, :integer, default: nil
  end
end
