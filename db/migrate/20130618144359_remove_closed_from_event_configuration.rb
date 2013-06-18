class RemoveClosedFromEventConfiguration < ActiveRecord::Migration
  def up
    remove_column :event_configurations, :closed
  end

  def down
    add_column :event_configurations, :closed, :boolean
  end
end
