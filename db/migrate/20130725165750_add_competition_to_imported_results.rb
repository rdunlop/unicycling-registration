class AddCompetitionToImportedResults < ActiveRecord::Migration
  def change
    add_column :import_results, :competition_id, :integer
  end
end
