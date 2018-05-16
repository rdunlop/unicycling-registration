class AddCompetitionToImportedResults < ActiveRecord::Migration[4.2]
  def change
    add_column :import_results, :competition_id, :integer
  end
end
