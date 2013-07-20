class AddCompetitionModel < ActiveRecord::Migration

  def up
    # create the competitions table
    create_table :competitions do |t|
      t.integer :event_id
      t.string :name
      t.boolean :locked
      t.timestamps
    end

    add_index :competitions, ["event_id"], :name => "index_competitions_event_id"

    # Associate competitors with the competition
    rename_column :competitors, :event_category_id, :competition_id

    # EventCategory no longer needs to be lock-able
    remove_column :event_categories, :locked

    # Judges are for competitions
    rename_column :judges, :event_category_id, :competition_id

    # Time Results are for a competitor(NOTE: this is adding a layer of abstraction, so that it's like everything else)
    rename_column :time_results, :event_category_id, :competitor_id
    rename_column :time_results, :registrant_id, :judge_id
  end

  def down
    drop_table :competitions
    rename_column :competitors, :competition_id, :event_category_id
    add_column :event_categories, :locked, :boolean
    rename_column :judges, :competition_id, :event_category_id
    rename_column :time_results, :competitor_id, :event_category_id
    rename_column :time_results, :judge_id, :registrant_id
  end
end
