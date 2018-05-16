class AddPositionToAgeGroupEntryTable < ActiveRecord::Migration[4.2]
  def change
    add_column :age_group_entries, :position, :integer
  end
end
