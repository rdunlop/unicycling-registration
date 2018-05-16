class AddCounterCacheToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :event_categories_count, :integer, null: false, default: 0
  end
end
