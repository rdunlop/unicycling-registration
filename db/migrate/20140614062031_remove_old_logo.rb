class RemoveOldLogo < ActiveRecord::Migration
  def change
    remove_column :event_configurations, :logo_binary, :binary
    remove_column :event_configurations, :logo_filename, :string
    remove_column :event_configurations, :logo_type, :string
  end
end
