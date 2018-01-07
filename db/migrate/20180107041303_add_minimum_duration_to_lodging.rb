class AddMinimumDurationToLodging < ActiveRecord::Migration[5.1]
  def change
    add_column :lodging_room_types, :minimum_duration_days, :integer, default: 0, null: false
  end
end
