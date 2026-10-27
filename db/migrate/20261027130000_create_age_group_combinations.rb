class CreateAgeGroupCombinations < ActiveRecord::Migration[8.1]
  def change
    create_table :age_group_combinations do |t|
      t.references :competition, null: false, index: true, foreign_key: true
      t.timestamps
    end

    create_table :age_group_combination_entries do |t|
      t.references :age_group_combination, null: false, index: true, foreign_key: true
      t.references :age_group_entry, null: false, index: true, foreign_key: true
      # Denormalized from the combination, so that the database ensures
      # an age group entry is part of a single combination per competition
      t.references :competition, null: false, index: false, foreign_key: true
      t.timestamps
    end
    add_index :age_group_combination_entries, %i[competition_id age_group_entry_id], unique: true, name: "index_age_group_combination_entries_unique"

    add_reference :published_age_group_entries, :age_group_combination, index: true, foreign_key: true

    # Not validated, so that legacy rows do not block the migration
    add_check_constraint :published_age_group_entries,
                         "(age_group_entry_id IS NULL) <> (age_group_combination_id IS NULL)",
                         name: "published_age_group_entries_exactly_one_age_group",
                         validate: false
  end
end
