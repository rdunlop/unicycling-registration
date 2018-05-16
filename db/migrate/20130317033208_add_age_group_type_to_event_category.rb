class AddAgeGroupTypeToEventCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :event_categories, :age_group_type_id, :integer
  end
end
