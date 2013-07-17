class RenameEventDescriptionToEventExportName < ActiveRecord::Migration
  def change
    rename_column :events, :description, :export_name
  end
end
