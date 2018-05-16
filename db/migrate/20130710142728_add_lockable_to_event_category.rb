class AddLockableToEventCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :event_categories, :locked, :boolean
  end
end
