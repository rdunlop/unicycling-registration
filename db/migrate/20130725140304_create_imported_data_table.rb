class CreateImportedDataTable < ActiveRecord::Migration
  def change
    create_table :import_results do |t|
      t.integer :user_id
      t.string :raw_data

      t.integer :bib_number
      t.integer :minutes
      t.integer :seconds
      t.integer :thousands
      t.boolean :disqualified
      t.timestamps
    end

    add_index :import_results, [:user_id], name: "index_imported_results_user_id"
  end
end
