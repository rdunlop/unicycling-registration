class CreateImportedRegistrants < ActiveRecord::Migration[7.0]
  def up
    create_table :imported_registrants do |t|
      t.string "first_name", null: false
      t.string "last_name", null: false
      t.date "birthday"
      t.string "gender"
      t.boolean "deleted", default: false, null: false
      t.integer "bib_number", null: false
      t.integer "age"
      t.string "club"
      t.boolean "ineligible", default: false, null: false
      t.string "sorted_last_name"
      t.timestamps
    end
    add_index :imported_registrants, :bib_number, unique: true
    add_index :imported_registrants, :deleted

    add_column :event_configurations, :imported_registrants, :boolean, default: false, null: false

    add_column :members, :registrant_type, :string
    execute "UPDATE members set registrant_type = 'Registrant'"
  end

  def down
    drop_table :imported_registrants

    remove_column :event_configurations, :imported_registrants

    execute "DELETE FROM members where registrant_type != 'Registrant'"

    remove_column :members, :registrant_type
  end
end
