class AddEventCategoryGroupingTables < ActiveRecord::Migration[7.0]
  def up
    create_table :event_category_groupings do |t|
      t.timestamps
    end

    create_table :event_category_grouping_entries do |t|
      t.references :event_category_grouping, index: { name: "ecge_grouping" }
      t.references :event_category, index: { name: "ecge_event_category" }
      t.timestamps
    end
  end
end
