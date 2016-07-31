class AddAbilityToImportResultsIntoOtherCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :import_results_into_other_competition, :boolean, default: false, null: false
  end
end
