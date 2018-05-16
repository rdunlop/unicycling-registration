class AddAgeRangeToEventCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :event_categories, :age_range_start, :integer, default: 0
    add_column :event_categories, :age_range_end, :integer, default: 100
  end
end
