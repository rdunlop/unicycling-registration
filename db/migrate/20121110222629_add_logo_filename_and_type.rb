class AddLogoFilenameAndType < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :logo_filename, :string
    add_column :event_configurations, :logo_type, :string
    rename_column :event_configurations, :logo, :logo_binary
  end
end
