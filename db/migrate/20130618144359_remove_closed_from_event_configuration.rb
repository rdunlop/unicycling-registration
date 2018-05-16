class RemoveClosedFromEventConfiguration < ActiveRecord::Migration[4.2]
  def up
    remove_column :event_configurations, :closed
  end

  def down
    add_column :event_configurations, :closed, :boolean
  end
end
