class AddLodgingModels < ActiveRecord::Migration[5.1]
  def change
    create_table :lodgings do |t|
      t.integer :position
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    create_table :lodging_room_types do |t|
      t.integer :lodging_id, null: false, index: true
      t.integer :position
      t.string :name, null: false
      t.text :description
      t.boolean :visible, null: false, default: true
      t.integer :maximum_available
      t.timestamps
    end

    create_table :lodging_room_options do |t|
      t.integer :lodging_room_type_id, null: false, index: true
      t.integer :position
      t.string :name, null: false
      t.integer :price_cents, null: false, default: 0
      t.timestamps
    end

    create_table :lodging_days do |t|
      t.integer :lodging_room_option_id, null: false, index: true
      t.date :date_offered, null: false
      t.timestamps
    end
  end
end
