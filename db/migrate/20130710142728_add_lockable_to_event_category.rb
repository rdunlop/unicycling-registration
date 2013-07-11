class AddLockableToEventCategory < ActiveRecord::Migration
  def change
    add_column :event_categories, :locked, :boolean
  end
end
