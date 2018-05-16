class RenameExternalIdToBibNumber < ActiveRecord::Migration[4.2]
  def change
    rename_column :registrants, :external_id, :bib_number
  end
end
