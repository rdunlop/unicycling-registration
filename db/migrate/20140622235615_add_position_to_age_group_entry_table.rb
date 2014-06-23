class AddPositionToAgeGroupEntryTable < ActiveRecord::Migration
  def change
    add_column :age_group_entries, :position, :integer
  end
end
