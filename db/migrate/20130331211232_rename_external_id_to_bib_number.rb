class RenameExternalIdToBibNumber < ActiveRecord::Migration
  def change
    rename_column :registrants, :external_id, :bib_number
  end
end
