class CompetitorCreationDuringImport < ActiveRecord::Migration[7.0]
  def change
    add_column :competitions, :allow_competitor_creation_during_import_approval, :boolean, default: false, null: false
  end
end
