class RenameWaiverInEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    rename_column :event_configurations, :waiver, :has_print_waiver
  end
end
