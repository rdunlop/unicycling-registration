class CreateAgeGroupPositions < ActiveRecord::Migration[8.1]
  def change
    # Optional order of the age groups of a competition, overriding the order of its age group type
    create_table :age_group_positions do |t|
      t.references :competition, null: false, index: false, foreign_key: true
      t.references :age_group_entry, null: false, index: true, foreign_key: true
      t.integer :position, null: false
      t.timestamps
    end
    add_index :age_group_positions, %i[competition_id age_group_entry_id], unique: true, name: "index_age_group_positions_unique"
  end
end
