class AddLodgingPackage < ActiveRecord::Migration[5.1]
  def change
    create_table :lodging_packages do |t|
      t.integer :lodging_room_type_id, null: false, index: true
      t.integer :lodging_room_option_id, null: false, index: true
      t.integer :total_cost_cents, null: false
      t.timestamps
    end

    create_table :lodging_package_days do |t|
      t.integer :lodging_package_id, null: false, index: true
      t.integer :lodging_day_id, null: false, index: true
      t.timestamps
    end

    add_index :lodging_package_days, %i[lodging_package_id lodging_day_id], unique: true, name: "lodging_package_unique"
  end
end
