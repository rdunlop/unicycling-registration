class AddAgeGroupTypeToEventCategory < ActiveRecord::Migration
  def change
    add_column :event_categories, :age_group_type_id, :integer
  end
end
