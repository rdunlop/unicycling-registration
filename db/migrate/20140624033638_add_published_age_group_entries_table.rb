class AddPublishedAgeGroupEntriesTable < ActiveRecord::Migration
  def change
    create_table :published_age_group_entries do |t|
      t.references :competition
      t.references :age_group_entry
      t.datetime :published_at
      t.timestamps
    end
  end
end
