class AddRankToImportResultTable < ActiveRecord::Migration
  def change
    add_column :import_results, :rank, :integer
    add_column :import_results, :details, :string
  end
end
