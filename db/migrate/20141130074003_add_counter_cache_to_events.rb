class AddCounterCacheToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_categories_count, :integer, null: false, default: 0
  end
end
