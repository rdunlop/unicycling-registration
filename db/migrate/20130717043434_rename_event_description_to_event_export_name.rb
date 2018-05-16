class RenameEventDescriptionToEventExportName < ActiveRecord::Migration[4.2]
  def change
    rename_column :events, :description, :export_name
  end
end
