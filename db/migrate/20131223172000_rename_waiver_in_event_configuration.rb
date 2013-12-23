class RenameWaiverInEventConfiguration < ActiveRecord::Migration
  def change
    rename_column :event_configurations, :waiver, :has_print_waiver
  end
end
